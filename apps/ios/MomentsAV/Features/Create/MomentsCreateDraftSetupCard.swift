import AVSettingsFoundation
import SwiftUI

struct MomentsCreateDraftSetupCard: View {
    @Binding var form: MomentDraftForm
    let templateSelection: Binding<MomentTemplateID>
    let templates: [MomentTemplate]
    let isDraftLocked: Bool
    let isCreatingDraft: Bool
    let canCreateDraft: Bool
    let availabilityMessage: String?
    let createdProjectId: String?
    let isContinuingProject: Bool
    let canStartAnotherProject: Bool
    let draftErrorMessage: String?
    let workspaceSummary: MomentsCreateWorkspaceSummary
    let canAfford: (MomentTemplate) -> Bool
    let spendPlanDescription: (MomentTemplate) -> String
    let createDraft: () -> Void
    let startAnotherProject: () -> Void

    var body: some View {
        AVSettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Draft setup")
                    .font(.headline)

                Picker("Template", selection: templateSelection) {
                    ForEach(templates) { template in
                        Text(template.title).tag(template.id)
                    }
                }
                .disabled(isDraftLocked)

                TextField("Occasion", text: $form.occasion)
                    .disabled(isDraftLocked)
                TextField("Who is this for?", text: $form.recipient)
                    .disabled(isDraftLocked)

                Picker("Tone", selection: $form.tone) {
                    ForEach(MomentDraftTone.allCases) { tone in
                        Text(tone.title).tag(tone)
                    }
                }
                .disabled(isDraftLocked)

                Picker("Tempo", selection: $form.tempo) {
                    ForEach(MomentDraftTempo.allCases) { tempo in
                        Text(tempo.title).tag(tempo)
                    }
                }
                .disabled(isDraftLocked)

                TextField("Details for Avi", text: $form.details, axis: .vertical)
                    .lineLimit(3...5)
                    .disabled(isDraftLocked)

                Divider()

                MomentsCreateTemplateSummary(
                    template: form.template,
                    canAfford: canAfford(form.template),
                    spendPlanDescription: spendPlanDescription(form.template)
                )

                Button(action: createDraft) {
                    Text(isCreatingDraft ? "Creating draft..." : "Create draft")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canCreateDraft || isCreatingDraft)

                if let availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                if let createdProjectId {
                    Text("\(activeProjectLabel): \(createdProjectId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(activeProjectDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()

                    MomentsCreateWorkspaceProgress(
                        summary: workspaceSummary,
                        minimumMediaCount: form.template.minimumAssets,
                    )

                    Button(action: startAnotherProject) {
                        Label("Start another project", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canStartAnotherProject)
                }

                if let draftErrorMessage {
                    Text(draftErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private var activeProjectLabel: String {
        isContinuingProject ? "Continuing project" : "Draft created"
    }

    private var activeProjectDetail: String {
        isContinuingProject
            ? "Create is attached to this existing project."
            : "Draft setup is locked for this project."
    }
}

struct MomentsCreateTemplateSummary: View {
    let template: MomentTemplate
    let canAfford: Bool
    let spendPlanDescription: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(template.title)
                        .font(.headline)
                    Text(template.summary)
                        .foregroundStyle(.secondary)
                    Text("\(template.duration) · \(template.mediaRange)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(spendPlanDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(template.creditCost) cr")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(canAfford ? .green : .secondary)
            }
        }
    }
}
