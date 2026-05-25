import SwiftUI

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
