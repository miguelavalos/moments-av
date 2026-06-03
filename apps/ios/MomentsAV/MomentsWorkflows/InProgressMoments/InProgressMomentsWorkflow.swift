import Combine
import Foundation
import OSLog

@MainActor
final class InProgressMomentsWorkflow: ObservableObject {
    @Published private(set) var momentsSummary = InProgressMomentsSummary()
    @Published private(set) var isDeletingMoment = false
    @Published private(set) var errorMessage: String?

    private let momentsObserver: any InProgressMomentsListProviding
    private let workspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow
    private let momentDeletionWorkflow: MomentDeletionWorkflow
    private let currentUserProvider: any MomentsCurrentUserProviding
    private let authTokenProvider: any MomentsAuthTokenProviding
    private let finalRenderResultSaver: any MomentsFinalRenderResultSaving
    private let statusClient: MomentsRenderStatusClient
    private let logger = Logger(subsystem: "com.avalsys.momentsav", category: "in-progress")
    private var currentOwnerUserId: String?
    private var isRefreshingFinalRenderStatus = false
    private var cancellables = Set<AnyCancellable>()

    init(
        momentsObserver: any InProgressMomentsListProviding,
        workspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow,
        momentDeletionWorkflow: MomentDeletionWorkflow,
        currentUserProvider: any MomentsCurrentUserProviding,
        authTokenProvider: any MomentsAuthTokenProviding,
        finalRenderResultSaver: any MomentsFinalRenderResultSaving,
        statusClient: MomentsRenderStatusClient
    ) {
        self.momentsObserver = momentsObserver
        self.workspaceSelectionWorkflow = workspaceSelectionWorkflow
        self.momentDeletionWorkflow = momentDeletionWorkflow
        self.currentUserProvider = currentUserProvider
        self.authTokenProvider = authTokenProvider
        self.finalRenderResultSaver = finalRenderResultSaver
        self.statusClient = statusClient

        momentsObserver.momentsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] moments in
                self?.apply(moments)
            }
            .store(in: &cancellables)

        momentsObserver.momentsErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.applyMomentListError(message)
            }
            .store(in: &cancellables)

        momentDeletionWorkflow.isDeletingMomentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleting in
                self?.isDeletingMoment = isDeleting
            }
            .store(in: &cancellables)

        momentDeletionWorkflow.deletionErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.applyMomentDeletionError(message)
            }
            .store(in: &cancellables)

        workspaceSelectionWorkflow.workspaceErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.applyWorkspaceError(message)
            }
            .store(in: &cancellables)
    }

    func observeInProgressMoments(ownerUserId: String?) {
        currentOwnerUserId = ownerUserId
        momentsSummary = InProgressMomentsSummary()
        errorMessage = nil
        clearActiveMoment()
        momentsObserver.observeInProgressMoments(ownerUserId: ownerUserId)
    }

    func observeMomentWorkspace(ownerUserId: String?, momentId: String?) {
        errorMessage = nil
        workspaceSelectionWorkflow.observeMomentWorkspace(ownerUserId: ownerUserId, momentId: momentId)
    }

    private func applyWorkspaceError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    func clearMomentWorkspace() {
        clearActiveMoment()
    }

    func refreshActiveFinalRenderStatusIfNeeded() async {
        guard !isRefreshingFinalRenderStatus,
              finalRenderResultSaver.isConfigured,
              statusClient.isConfigured,
              let workspace = workspaceSelectionWorkflow.activeWorkspace,
              !workspace.hasAvailableArtifact(kind: "final_export"),
              let activeFinalRenderJob = workspace.activeFinalRenderJob else {
            return
        }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = L10n.string("workflow.final.refreshSignIn")
            return
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            errorMessage = L10n.string("workflow.final.refreshSignIn")
            return
        }

        isRefreshingFinalRenderStatus = true
        defer { isRefreshingFinalRenderStatus = false }

        do {
            let refresh = try RenderJobStatusRefresh.make(
                momentId: workspace.moment.id,
                job: activeFinalRenderJob,
                missingMomentMessage: refreshMessages.missingMoment,
                missingJobMessage: refreshMessages.missingJob,
                missingProviderRequestMessage: refreshMessages.missingProviderRequest
            )
            let status = try await refresh.fetchStatus(
                bearerToken: bearerToken,
                statusClient: statusClient,
                usesProviderReconciliation: true
            )
            let didAttachFinalArtifact = try await refresh.saveCompletedFinalArtifactIfNeeded(
                ownerUserId: ownerUserId,
                status: status,
                workspace: workspaceSelectionWorkflow.activeWorkspace,
                statusUpdater: finalRenderResultSaver
            )
            do {
                try await refresh.saveStatus(
                    ownerUserId: ownerUserId,
                    status: status,
                    statusUpdater: finalRenderResultSaver
                )
            } catch {
                guard didAttachFinalArtifact else { throw error }
                logger.error("Final render status update failed after artifact attach momentId=\(refresh.momentId, privacy: .public) renderJobId=\(refresh.job.id, privacy: .public) reason=\(String(describing: error), privacy: .public)")
            }
            workspaceSelectionWorkflow.observeMomentWorkspace(ownerUserId: ownerUserId, momentId: refresh.momentId)
            errorMessage = nil
        } catch {
            errorMessage = MomentsRecoveryCopy.renderRefreshFailure()
        }
    }

    func deleteMoment(_ moment: InProgressMoment) async -> Bool {
        errorMessage = nil
        let didDelete = await momentDeletionWorkflow.deleteMoment(moment)
        guard didDelete else { return false }

        if workspaceSelectionWorkflow.activeMoment?.id == moment.id {
            clearActiveMoment()
        }
        observeInProgressMoments(ownerUserId: currentOwnerUserId)
        return true
    }

    private func apply(_ moments: [InProgressMoment]) {
        momentsSummary = InProgressMomentsSummary.make(from: moments)
    }

    private func applyMomentListError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    private func applyMomentDeletionError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    private func clearActiveMoment() {
        workspaceSelectionWorkflow.clearMomentWorkspace()
    }

    private var refreshMessages: RenderJobStatusRefreshMessages {
        RenderJobStatusRefreshMessages(
            signIn: L10n.string("workflow.final.refreshSignIn"),
            missingMoment: L10n.string("workflow.final.refreshMissingMoment"),
            missingJob: L10n.string("workflow.final.refreshMissingJob"),
            missingProviderRequest: MomentsRecoveryCopy.finalRenderStatusMissing(),
            success: L10n.string("workflow.final.refreshSuccess")
        )
    }
}

extension InProgressMomentsWorkflow: InProgressMomentsViewing {
    var inProgressSummaryPublisher: AnyPublisher<InProgressMomentsSummary, Never> {
        $momentsSummary.eraseToAnyPublisher()
    }

    var activeMomentPublisher: AnyPublisher<InProgressMoment?, Never> {
        workspaceSelectionWorkflow.activeMomentPublisher
    }

    var activeWorkspacePublisher: AnyPublisher<MomentWorkspace?, Never> {
        workspaceSelectionWorkflow.activeWorkspacePublisher
    }

    var isLoadingMomentWorkspacePublisher: AnyPublisher<Bool, Never> {
        workspaceSelectionWorkflow.isLoadingMomentWorkspacePublisher
    }

    var isDeletingMomentPublisher: AnyPublisher<Bool, Never> {
        $isDeletingMoment.eraseToAnyPublisher()
    }

    var inProgressErrorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
}
