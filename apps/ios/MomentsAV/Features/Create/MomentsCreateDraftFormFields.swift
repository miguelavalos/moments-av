import SwiftUI

struct MomentsCreateDraftFormFields: View {
    @Binding var form: MomentDraftForm
    let templateSelection: Binding<MomentTemplateID>
    let templates: [MomentTemplate]
    let isDraftLocked: Bool

    var body: some View {
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
    }
}
