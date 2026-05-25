import SwiftUI

struct MomentsProjectsListSummaryRow: View {
    let pills: [MomentsProjectsListSummaryPresentation]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(pills) { pill in
                MomentsProjectsListSummaryPill(pill: pill)
            }
        }
    }
}

