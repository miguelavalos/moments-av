import AVSettingsFoundation
import SwiftUI

struct MomentsCreateDraftSetupCard: View {
    @Binding var form: MomentDraftForm
    let templateSelection: Binding<MomentTemplateID>
    let templates: [MomentTemplate]
    let presentation: MomentsCreateDraftSetupPresentation
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
                .disabled(presentation.isDraftLocked)

                TextField("Occasion", text: $form.occasion)
                    .disabled(presentation.isDraftLocked)
                TextField("Who is this for?", text: $form.recipient)
                    .disabled(presentation.isDraftLocked)

                Picker("Tone", selection: $form.tone) {
                    ForEach(MomentDraftTone.allCases) { tone in
                        Text(tone.title).tag(tone)
                    }
                }
                .disabled(presentation.isDraftLocked)

                Picker("Tempo", selection: $form.tempo) {
                    ForEach(MomentDraftTempo.allCases) { tempo in
                        Text(tempo.title).tag(tempo)
                    }
                }
                .disabled(presentation.isDraftLocked)

                TextField("Details for Avi", text: $form.details, axis: .vertical)
                    .lineLimit(3...5)
                    .disabled(presentation.isDraftLocked)

                Divider()

                MomentsCreateTemplateSummary(presentation: presentation.templateSummary)

                Button(action: createDraft) {
                    Text(presentation.createDraftTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!presentation.canCreateDraft || presentation.isCreatingDraft)

                if let availabilityMessage = presentation.availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                if let activeProjectId = presentation.activeProjectId {
                    Text("\(presentation.activeProjectLabel): \(activeProjectId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(presentation.activeProjectDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()

                    MomentsCreateWorkspaceProgress(
                        summary: presentation.workspaceSummary,
                        minimumMediaCount: form.template.minimumAssets,
                    )

                    Button(action: startAnotherProject) {
                        Label("Start another project", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!presentation.canStartAnotherProject)
                }

                if let draftErrorMessage = presentation.draftErrorMessage {
                    Text(draftErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

struct MomentsCreateTemplateSummary: View {
    let presentation: MomentsCreateTemplateSummaryPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(presentation.template.title)
                        .font(.headline)
                    Text(presentation.template.summary)
                        .foregroundStyle(.secondary)
                    Text(presentation.metadataTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(presentation.spendPlanDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(presentation.creditTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(presentation.canAfford ? .green : .secondary)
            }
        }
    }
}
