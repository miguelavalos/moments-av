import SwiftUI

struct DraftFlowView: View {
    let template: MomentTemplate

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore
    @Environment(\.dismiss) private var dismiss
    @State private var form: MomentDraftForm
    @State private var createdProjectId: String?

    init(template: MomentTemplate) {
        self.template = template
        _form = State(initialValue: MomentDraftForm(template: template))
    }

    private var canAfford: Bool {
        MomentsCreditGate.canAfford(template, balance: accountController.creditBalance)
    }

    private var canCreateDraft: Bool {
        accountController.user != nil && canAfford && form.canCreateDraft && projectStore.isConfigured
    }

    var body: some View {
        Form {
            Section("Template") {
                TemplateSummaryRows(template: template)
                if template.id == .softRoast {
                    Label("Keep it light, affectionate, and only for people who are in on the joke.", systemImage: "heart")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                AviCompanionView(
                    state: .onboarding,
                    message: "Add enough context for a useful draft. You can edit scenes before preview and final export."
                )
            }

            Section("Occasion") {
                TextField("Occasion", text: $form.occasion)
                TextField("Who is this for?", text: $form.recipient)
            }

            Section("Avi Direction") {
                Picker("Tone", selection: $form.tone) {
                    ForEach(MomentDraftTone.allCases) { tone in
                        Text(tone.title).tag(tone)
                    }
                }

                Picker("Tempo", selection: $form.tempo) {
                    ForEach(MomentDraftTempo.allCases) { tempo in
                        Text(tempo.title).tag(tempo)
                    }
                }

                TextField("Details for Avi", text: $form.details, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Before Generation") {
                LabeledContent("Duration", value: template.duration)
                LabeledContent("Credit cost", value: "\(template.creditCost)")
                LabeledContent("Media needed", value: template.mediaRange)
                SpendPlanView(template: template, balance: accountController.creditBalance)
                Text("Preview checks require spendable credits, and final credits are committed only after a usable export is delivered.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let activeProject = projectStore.activeProject, activeProject.id == createdProjectId {
                Section("Draft State") {
                    ProjectStateView(project: activeProject)
                }

                MediaSelectionView(template: template, projectId: activeProject.id)

                StoryDraftView(
                    template: template,
                    projectId: activeProject.id,
                    form: form,
                    mediaAssets: projectStore.activeWorkspace?.mediaAssets ?? [],
                    savedScenes: projectStore.activeWorkspace?.storyScenes ?? []
                )

                PreviewGenerationView(
                    template: template,
                    project: activeProject,
                    latestPreview: projectStore.activeWorkspace?.artifacts.first { $0.kind == "preview" },
                    latestRenderJob: projectStore.activeWorkspace?.renderJobs.first { $0.kind == "preview" }
                )

                FinalRenderView(
                    template: template,
                    project: activeProject,
                    latestPreview: projectStore.activeWorkspace?.artifacts.first { $0.kind == "preview" },
                    finalExport: projectStore.activeWorkspace?.artifacts.first { $0.kind == "final_export" },
                    latestRenderJob: projectStore.activeWorkspace?.renderJobs.first { $0.kind == "final" }
                )

                ProjectDeletionView(project: activeProject) {
                    createdProjectId = nil
                    dismiss()
                }
            }

            Section {
                Button {
                    Task { await createDraft() }
                } label: {
                    Label(projectStore.isCreatingDraft ? "Creating Draft" : "Create Draft", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!canCreateDraft || projectStore.isCreatingDraft)
            } footer: {
                if accountController.user == nil {
                    Text("Sign in before starting a draft.")
                } else if !canAfford {
                    Text("Add credits before creating this draft.")
                } else if !projectStore.isConfigured {
                    Text("Project sync is not configured for this build.")
                }
            }
        }
        .navigationTitle(template.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Project sync failed", isPresented: storeErrorIsPresented) {
            Button("OK", role: .cancel) {
                projectStore.errorMessage = nil
            }
        } message: {
            Text(projectStore.errorMessage ?? "")
        }
    }

    private var storeErrorIsPresented: Binding<Bool> {
        Binding(
            get: { projectStore.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    projectStore.errorMessage = nil
                }
            }
        )
    }

    private func createDraft() async {
        guard let ownerUserId = accountController.user?.id else { return }
        createdProjectId = await projectStore.createDraft(ownerUserId: ownerUserId, form: form)
    }
}

struct TemplateSummaryRows: View {
    let template: MomentTemplate

    var body: some View {
        LabeledContent("Format", value: template.title)
        LabeledContent("Duration", value: template.duration)
        LabeledContent("Credits", value: "\(template.creditCost)")
        LabeledContent("Media", value: template.mediaRange)
    }
}

struct SpendPlanView: View {
    let template: MomentTemplate
    let balance: MomentsCreditBalance

    var body: some View {
        if let spendPlan = MomentsCreditGate.spendPlan(for: template.creditCost, balance: balance) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Spend order")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("Pro \(spendPlan.proMonthly) · Promo \(spendPlan.promotional) · Purchased \(spendPlan.purchased)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("Not enough spendable credits.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ProjectStateView: View {
    let project: MomentDraftProject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(project.status.capitalized, systemImage: "dot.radiowaves.left.and.right")
            Text(project.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Preview \(Int(project.previewCount))/\(Int(project.previewLimit))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
