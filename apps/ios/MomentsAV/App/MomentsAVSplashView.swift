import AVBrandFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAVSplashView: View {
    var body: some View {
        AVConfiguredSplashScreen()
    }
}

#Preview {
    MomentsAVSplashView()
        .avBrandPalette(MomentsTheme.brandPalette)
}
