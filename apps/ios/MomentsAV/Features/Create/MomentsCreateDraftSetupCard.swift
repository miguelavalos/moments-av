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

                MomentsCreateDraftFormFields(
                    form: $form,
                    templateSelection: templateSelection,
                    templates: templates,
                    isDraftLocked: presentation.isDraftLocked
                )

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

                MomentsCreateActiveDraftSection(
                    presentation: presentation,
                    minimumMediaCount: form.template.minimumAssets,
                    startAnotherProject: startAnotherProject
                )

                if let draftErrorMessage = presentation.draftErrorMessage {
                    Text(draftErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
