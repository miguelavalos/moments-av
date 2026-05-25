import SwiftUI

struct MomentsHomeLatestProjectRow: View {
    let title: String
    let detail: String
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
                    Text(detail)
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
}

struct MomentsHomeEmptyProjectRow: View {
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
