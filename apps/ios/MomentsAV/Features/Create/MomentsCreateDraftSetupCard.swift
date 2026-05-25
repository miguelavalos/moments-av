import AVAppShellFoundation
import SwiftUI

struct MomentsCreateDraftSetupCard: View {
    @Binding var form: MomentDraftForm
    let templateSelection: Binding<MomentTemplateID>
    let templates: [MomentTemplate]
    let presentation: MomentsCreateDraftSetupPresentation
    let createDraft: () -> Void
    let startAnotherProject: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 14) {
                AVAppShellContentHeader(
                    title: "Draft setup",
                    detail: "Name the memory, choose the format, and prepare the project draft."
                )

                MomentsCreateDraftFormFields(
                    form: $form,
                    templateSelection: templateSelection,
                    templates: templates,
                    isDraftLocked: presentation.isDraftLocked
                )

                Divider()

                MomentsCreateTemplateSummary(presentation: presentation.templateSummary)

                AVAppShellPrimaryButton(
                    presentation.createDraftTitle,
                    systemImage: "plus.app.fill",
                    isDisabled: !presentation.canCreateDraft || presentation.isCreatingDraft,
                    action: createDraft
                )

                if let availabilityMessage = presentation.availabilityMessage {
                    AVAppShellInlineMessage(message: availabilityMessage)
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
