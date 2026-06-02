import SwiftUI

struct MomentsInProgressListSummaryRow: View {
    let pills: [MomentsProjectListSummaryPresentation]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(pills) { pill in
                MomentsInProgressListSummaryPill(pill: pill)
            }
        }
    }
}

