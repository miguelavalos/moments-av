import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case create
    case projects
    case account
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .create: "Create"
        case .projects: "Projects"
        case .account: "Account"
        case .settings: "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .create: "sparkles"
        case .projects: "rectangle.stack"
        case .account: "person.crop.circle"
        case .settings: "gearshape"
        }
    }
}

struct RootView: View {
    @State private var selectedTab: AppTab = .create

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tabContent(for: tab)
                        .navigationTitle(tab.title)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.symbolName)
                }
                .tag(tab)
            }
        }
        .tint(MomentsTheme.accent)
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .create:
            CreateMomentView()
        case .projects:
            ProjectsView()
        case .account:
            AccountPlaceholderView()
        case .settings:
            SettingsView()
        }
    }
}

struct CreateMomentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AppHeader()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose a memory format")
                        .font(.title2.weight(.semibold))

                    ForEach(MomentTemplate.sample) { template in
                        TemplateCard(template: template)
                    }
                }

                GuidePanel(
                    title: "Avi helps shape the story",
                    text: "Pick the template and media first. Story drafts, previews, and exports unlock after sign-in and project setup are connected."
                )
            }
            .padding(20)
        }
        .background(MomentsTheme.background)
    }
}

struct ProjectsView: View {
    var body: some View {
        ContentUnavailableView(
            "No projects yet",
            systemImage: "film.stack",
            description: Text("Drafts and exports will appear here after project sync is connected.")
        )
        .background(MomentsTheme.background)
    }
}

struct AccountPlaceholderView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 52))
                .foregroundStyle(MomentsTheme.accent)
            Text("Account")
                .font(.title2.weight(.semibold))
            Text("Sign-in and Apps AV account controls are added in the next implementation slice.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MomentsTheme.background)
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Section("Privacy") {
                Label("Private by default", systemImage: "lock")
                Label("User-controlled export", systemImage: "square.and.arrow.up")
            }

            Section("Support") {
                Link("Support", destination: URL(string: "https://moments-av.avalsys.com/support")!)
                Link("Privacy Policy", destination: URL(string: "https://moments-av.avalsys.com/privacy")!)
            }
        }
        .scrollContentBackground(.hidden)
        .background(MomentsTheme.background)
    }
}

struct AppHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Moments AV")
                .font(.largeTitle.weight(.bold))
            Text("Turn selected photos and short clips into private memory videos.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct TemplateCard: View {
    let template: MomentTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(template.title)
                    .font(.headline)
                Spacer()
                Text(template.duration)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MomentsTheme.accent)
            }

            Text(template.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(template.mediaRange, systemImage: "photo.on.rectangle.angled")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct GuidePanel: View {
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.title3)
                .foregroundStyle(MomentsTheme.accent)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(MomentsTheme.panel, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct MomentTemplate: Identifiable {
    let id: String
    let title: String
    let duration: String
    let mediaRange: String
    let summary: String

    static let sample = [
        MomentTemplate(
            id: "birthday",
            title: "Birthday Message",
            duration: "30 sec",
            mediaRange: "3-20 photos or clips",
            summary: "A warm greeting built from selected memories and captions."
        ),
        MomentTemplate(
            id: "party",
            title: "Party Recap",
            duration: "45 sec",
            mediaRange: "6-40 photos or clips",
            summary: "A quick montage for gatherings, trips, and shared celebrations."
        ),
        MomentTemplate(
            id: "soft-roast",
            title: "Soft Roast",
            duration: "30 sec",
            mediaRange: "3-20 photos or clips",
            summary: "Light, affectionate humor for people who are in on the joke."
        )
    ]
}

enum MomentsTheme {
    static let accent = Color(red: 0.85, green: 0.36, blue: 0.28)
    static let background = Color(red: 0.97, green: 0.94, blue: 0.91)
    static let panel = Color(red: 1.0, green: 0.98, blue: 0.95)
}

#Preview {
    RootView()
}
