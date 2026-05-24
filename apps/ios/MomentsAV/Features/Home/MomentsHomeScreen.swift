import AVSettingsFoundation
import SwiftUI

struct MomentsHomeScreen: View {
    @EnvironmentObject private var viewModel: MomentsHomeViewModel

    let selectTab: (MomentsRootTab) -> Void
    let continueProject: (MomentDraftProject) -> Void
    let signInActions: AnyView
    private var projectSummary: MomentsProjectListSummary { viewModel.projectSummary }
    private var latestInProgressProject: MomentDraftProject? {
        projectSummary.groups.inProgress.first
    }

    init(
        selectTab: @escaping (MomentsRootTab) -> Void,
        continueProject: @escaping (MomentDraftProject) -> Void,
        signInActions: AnyView
    ) {
        self.selectTab = selectTab
        self.continueProject = continueProject
        self.signInActions = signInActions
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                AVSettingsScreenHeader(
                    title: "Moments AV",
                    subtitle: "Private memory videos guided by Avi, with simple project tracking from draft to final export."
                )

                AVSettingsCard {
                    MomentsHomeSectionHeader(
                        title: viewModel.isSignedIn ? "Account connected" : "Account required",
                        detail: viewModel.isSignedIn
                            ? "Signed in as \(viewModel.displayName ?? "Moments AV user")."
                            : "Sign in is required before creating, rendering, and managing projects."
                    )

                    if viewModel.isSignedIn {
                        HStack(spacing: 10) {
                            MomentsHomeMetricTile(
                                title: "Spendable",
                                value: "\(viewModel.creditBalance.spendable)",
                                systemImage: "creditcard"
                            )
                            MomentsHomeMetricTile(
                                title: "Projects",
                                value: "\(projectSummary.projectCount)",
                                systemImage: "rectangle.stack"
                            )
                        }
                        MomentsHomeCreditBreakdown(balance: viewModel.creditBalance)
                    } else {
                        signInActions
                    }
                }

                AVSettingsCard {
                    MomentsHomeSectionHeader(
                        title: "Project status",
                        detail: projectSummary.hasProjects
                            ? "\(projectSummary.projectCount) synced projects tracked across the current account."
                            : "No synced projects yet."
                    )

                    if let latestProject = projectSummary.latestProject {
                        MomentsHomeLatestProjectRow(
                            title: latestProject.title,
                            status: MomentsProjectStatusRules.displayTitle(for: latestProject.status),
                            updatedAt: latestProject.updatedAt,
                            openProject: { selectTab(.projects) }
                        )
                    } else if viewModel.isSignedIn {
                        MomentsHomeEmptyProjectRow()
                    }

                    HStack(spacing: 10) {
                        MomentsHomeMetricTile(
                            title: "In progress",
                            value: "\(projectSummary.inProgressCount)",
                            systemImage: "clock"
                        )
                        MomentsHomeMetricTile(
                            title: "Finished",
                            value: "\(projectSummary.finishedCount)",
                            systemImage: "checkmark.circle"
                        )
                    }
                }

                AVSettingsCard {
                    MomentsHomeSectionHeader(
                        title: "Next actions",
                        detail: "Move between creation, project review, and Avi guidance without leaving the new shell."
                    )

                    VStack(spacing: 10) {
                        if let latestInProgressProject {
                            MomentsHomeActionRow(
                                title: "Continue latest project",
                                detail: "\(latestInProgressProject.title) is ready to review in Create.",
                                systemImage: "arrow.right.circle",
                                isProminent: true
                            ) {
                                continueProject(latestInProgressProject)
                            }
                        }

                        MomentsHomeActionRow(
                            title: "Create a moment",
                            detail: "Pick the occasion, add media, draft the story, then render.",
                            systemImage: "plus.app",
                            isProminent: latestInProgressProject == nil,
                            isDisabled: !viewModel.isSignedIn
                        ) {
                            selectTab(.create)
                        }

                        MomentsHomeActionRow(
                            title: "Review projects",
                            detail: projectSummary.hasProjects
                                ? "Open \(projectSummary.projectCount) synced projects with preview and final status."
                                : "Project workspace details will appear after the first synced draft.",
                            systemImage: "rectangle.stack",
                            isDisabled: !viewModel.isSignedIn
                        ) {
                            selectTab(.projects)
                        }

                        MomentsHomeActionRow(
                            title: "Ask Avi for guidance",
                            detail: "Use Avi for media, story, preview, render, and credit guidance.",
                            systemImage: "sparkles"
                        ) {
                            selectTab(.avi)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(MomentsTheme.canvas.ignoresSafeArea())
        .navigationTitle("Home")
    }
}

private struct MomentsHomeSectionHeader: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct MomentsHomeLatestProjectRow: View {
    let title: String
    let status: String?
    let updatedAt: Double?
    let openProject: () -> Void

    var body: some View {
        Button(action: openProject) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MomentsTheme.brandPalette.accent)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Latest project")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Text(detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(12)
            .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private var detailText: String {
        [status, formattedUpdatedAt].compactMap { $0 }.joined(separator: " · ")
    }

    private var formattedUpdatedAt: String? {
        guard let updatedAt else { return nil }
        return "Updated \(MomentsDateFormatting.formattedDate(milliseconds: updatedAt))"
    }
}

private struct MomentsHomeEmptyProjectRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text("No projects yet")
                    .font(.subheadline.weight(.semibold))
                Text("Start in Create to sync the first draft, preview, and final export.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MomentsHomeCreditBreakdown: View {
    let balance: MomentsCreditBalance

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CreditSource.allCases, id: \.rawValue) { source in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(balance.amount(for: source))")
                        .font(.caption.weight(.semibold))
                    Text(source.shortTitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .padding(8)
                .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

private extension CreditSource {
    var shortTitle: String {
        switch self {
        case .proMonthly: "Monthly"
        case .promotional: "Promo"
        case .purchased: "Purchased"
        }
    }
}

private struct MomentsHomeMetricTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
            Text(value)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.76)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(MomentsTheme.brandPalette.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MomentsHomeActionRow: View {
    let title: String
    let detail: String
    let systemImage: String
    var isProminent = false
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isProminent ? .white : MomentsTheme.brandPalette.accent)
                    .frame(width: 26, height: 26)
                    .background(iconBackground, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(rowBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.55 : 1)
    }

    private var iconBackground: Color {
        isProminent ? MomentsTheme.brandPalette.accent : MomentsTheme.brandPalette.accent.opacity(0.12)
    }

    private var rowBackground: Color {
        isProminent ? MomentsTheme.brandPalette.accent.opacity(0.08) : Color.primary.opacity(0.03)
    }

    private var rowBorder: Color {
        isProminent ? MomentsTheme.brandPalette.accent.opacity(0.20) : Color.primary.opacity(0.06)
    }
}
