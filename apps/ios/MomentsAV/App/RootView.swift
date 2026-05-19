import AccountAV
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case create
    case projects
    case avi
    case account

    var id: String { rawValue }

    var title: String {
        switch self {
        case .create: "Create"
        case .projects: "Projects"
        case .avi: "Avi"
        case .account: "Account"
        }
    }

    var symbolName: String {
        switch self {
        case .create: "plus.app"
        case .projects: "rectangle.stack"
        case .avi: "sparkles"
        case .account: "person.crop.circle"
        }
    }
}

struct RootView: View {
    @StateObject private var accountController = AccountController()
    @StateObject private var projectStore = MomentsProjectStore()
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
        .tint(MomentsBrand.ColorToken.primaryAccent)
        .environmentObject(accountController)
        .environmentObject(projectStore)
        .onChange(of: accountController.user?.id, initial: true) { _, ownerUserId in
            projectStore.observeProjects(ownerUserId: ownerUserId)
        }
        .alert("Account action failed", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) {
                accountController.errorMessage = nil
            }
        } message: {
            Text(accountController.errorMessage ?? "")
        }
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(
            get: { accountController.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    accountController.errorMessage = nil
                }
            }
        )
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .create:
            CreateMomentView()
        case .projects:
            ProjectsView()
        case .avi:
            AviHomeView()
        case .account:
            AccountView()
        }
    }
}

struct CreateMomentView: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AppHeader()
                LaunchReadinessView(balance: accountController.creditBalance)

                if accountController.isSignedIn {
                    if MomentsCreditGate.canAffordAny(MomentTemplate.launchTemplates, balance: accountController.creditBalance) {
                        CreditBalanceSummary(balance: accountController.creditBalance)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose a memory format")
                                .font(.title2.weight(.semibold))

                            ForEach(MomentTemplate.launchTemplates) { template in
                                TemplateCard(
                                    template: template,
                                    balance: accountController.creditBalance
                                )
                            }
                        }

                        AviCompanionView(
                            state: .storyDraft,
                            message: "Preview and final render both require enough spendable credits for the selected template."
                        )
                    } else {
                        CreditRequiredView()
                    }
                } else {
                    SignedOutGateView()
                }
            }
            .padding(20)
        }
        .background(MomentsBrand.ColorToken.appBackground)
    }
}

struct SignedOutGateView: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Sign in to start a memory video", systemImage: "lock")
                .font(.title3.weight(.semibold))

            Text("Creation needs an Account AV session before photos, clips, or drafts can be attached to a private project.")
                .font(.body)
                .foregroundStyle(.secondary)

            AviCompanionView(
                state: .onboarding,
                message: "I can guide the project after sign-in, but private media and exports stay tied to Account AV."
            )

            AuthActionButtons()

            if !accountController.isAccountAvailable {
                Text("Account sign-in is not configured for this build.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(MomentsBrand.ColorToken.elevatedSurface, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
    }
}

struct CreditRequiredView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Credits required before creation", systemImage: "creditcard")
                .font(.title3.weight(.semibold))

            Text("Choose Pro monthly credits or an extra credit pack before starting a Moments AV project.")
                .font(.body)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                PurchaseRouteRow(title: "Pro monthly", detail: "Monthly final-render allowance")
                PurchaseRouteRow(title: "Credit packs", detail: "Extra credits for giftable exports")
            }

            Text("Delivered usable final renders consume credits and are not refunded for taste preferences.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            AviCompanionView(
                state: .creditExplanation,
                message: "Pick a credit path before creating so preview and export stay clear."
            )
        }
        .padding(18)
        .background(MomentsBrand.ColorToken.elevatedSurface, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
    }
}

struct PurchaseRouteRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle")
                .foregroundStyle(MomentsBrand.ColorToken.primaryAccent)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(MomentsBrand.ColorToken.panelBackground, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
    }
}

struct LaunchReadinessView: View {
    let balance: MomentsCreditBalance

    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Before you create")
                .font(.headline)

            ReadinessRow(
                title: "Account AV",
                detail: accountController.isSignedIn ? "Signed in and ready for private projects" : "Required before media, drafts, and exports",
                systemImage: accountController.isSignedIn ? "checkmark.circle.fill" : "person.crop.circle.badge.exclamationmark",
                isComplete: accountController.isSignedIn
            )

            ReadinessRow(
                title: "Credits",
                detail: balance.spendable > 0 ? "\(balance.spendable) spendable credits available" : "Needed before preview and final export",
                systemImage: balance.spendable > 0 ? "checkmark.circle.fill" : "creditcard",
                isComplete: balance.spendable > 0
            )

            ReadinessRow(
                title: "Avi workflow",
                detail: "Avi helps shape the draft, preview, and export status",
                systemImage: "sparkles",
                isComplete: true
            )
        }
        .padding(16)
        .background(MomentsBrand.ColorToken.elevatedSurface, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
    }
}

struct ReadinessRow: View {
    let title: String
    let detail: String
    let systemImage: String
    let isComplete: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(isComplete ? MomentsBrand.ColorToken.primaryAccent : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ProjectsView: View {
    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore

    var body: some View {
        Group {
            if accountController.isSignedIn && !projectStore.projects.isEmpty {
                List(projectStore.projects) { project in
                    NavigationLink {
                        DraftProjectDetailView(project: project)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.title)
                                .font(.headline)
                            Text("\(project.status.capitalized) · \(Int(project.durationSeconds)) sec · \(Int(project.creditCost)) credits")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            } else if accountController.isSignedIn {
                ContentUnavailableView(
                    "No projects yet",
                    systemImage: "film.stack",
                    description: Text(projectStore.isConfigured ? "Drafts and exports will appear here after creation." : "Project sync is not configured for this build.")
                )
            } else {
                VStack(spacing: 18) {
                    Image(systemName: "lock.rectangle.stack")
                        .font(.system(size: 48))
                        .foregroundStyle(MomentsBrand.ColorToken.primaryAccent)
                    Text("Sign in to view projects")
                        .font(.title2.weight(.semibold))
                    Text("Your Moments AV drafts and exports appear only after Account AV sign-in.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    AuthActionButtons()
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(MomentsBrand.ColorToken.appBackground)
    }
}

struct DraftProjectDetailView: View {
    let project: MomentDraftProject

    var body: some View {
        List {
            Section("Project") {
                LabeledContent("Title", value: project.title)
                LabeledContent("Status", value: project.status.capitalized)
                LabeledContent("Duration", value: "\(Int(project.durationSeconds)) sec")
                LabeledContent("Credits", value: "\(Int(project.creditCost))")
            }

            Section("Avi Direction") {
                if let occasion = project.occasion {
                    LabeledContent("Occasion", value: occasion)
                }
                if let tone = project.tone {
                    LabeledContent("Tone", value: tone.capitalized)
                }
                if let tempo = project.tempo {
                    LabeledContent("Tempo", value: tempo.capitalized)
                }
                if let details = project.details, !details.isEmpty {
                    Text(details)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Draft")
        .scrollContentBackground(.hidden)
        .background(MomentsBrand.ColorToken.appBackground)
    }
}

struct AccountView: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        List {
            Section("Account AV") {
                if let user = accountController.user {
                    LabeledContent("Status", value: "Signed in")
                    LabeledContent("Name", value: user.displayName)
                    if let email = user.emailAddress {
                        LabeledContent("Email", value: email)
                    }
                    Button("Sign Out", role: .destructive) {
                        accountController.signOut()
                    }
                    .disabled(accountController.isBusy)
                } else {
                    Text("Sign in before creating Moments AV projects.")
                        .foregroundStyle(.secondary)
                    AuthActionButtons()
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }

            if accountController.isSignedIn {
                Section("Credits") {
                    CreditSourceRow(source: .proMonthly, amount: accountController.creditBalance.proMonthly)
                    CreditSourceRow(source: .promotional, amount: accountController.creditBalance.promotional)
                    CreditSourceRow(source: .purchased, amount: accountController.creditBalance.purchased)
                    LabeledContent("Spendable", value: "\(accountController.creditBalance.spendable)")
                    Text("Preview checks require spendable credits. Delivered usable final exports commit credits; drafts and failed provider runs do not commit final credits.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Privacy") {
                Label("Private by default", systemImage: "lock")
                Label("User-controlled export", systemImage: "square.and.arrow.up")
                Text("Moments AV uses Account AV for identity. Selected media, drafts, previews, and exports remain tied to your account and project deletion removes project media and generated artifacts where available.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Support") {
                Link("Support", destination: AppConfig.supportURL)
                Link("Privacy Policy", destination: AppConfig.privacyPolicyURL)
                Link("Terms", destination: AppConfig.termsURL)
                Link("Delete Account", destination: AppConfig.accountDeletionURL)
            }
        }
        .scrollContentBackground(.hidden)
        .background(MomentsBrand.ColorToken.appBackground)
    }
}

struct AuthActionButtons: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        VStack(spacing: 10) {
            Button {
                accountController.signInWithApple()
            } label: {
                Label("Continue with Apple", systemImage: "apple.logo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                accountController.signInWithGoogle()
            } label: {
                Label("Continue with Google", systemImage: "globe")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .disabled(accountController.isBusy || !accountController.isAccountAvailable)
    }
}

struct CreditBalanceSummary: View {
    let balance: MomentsCreditBalance

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spendable credits")
                .font(.headline)
            HStack(spacing: 10) {
                CreditSourcePill(source: .proMonthly, amount: balance.proMonthly)
                CreditSourcePill(source: .promotional, amount: balance.promotional)
                CreditSourcePill(source: .purchased, amount: balance.purchased)
            }
            Text("Credits are spent in this order: Pro monthly, promotional, then purchased.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(MomentsBrand.ColorToken.elevatedSurface, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
    }
}

struct CreditSourcePill: View {
    let source: CreditSource
    let amount: Int

    var body: some View {
        VStack(spacing: 3) {
            Text("\(amount)")
                .font(.headline)
            Text(source.title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(MomentsBrand.ColorToken.panelBackground, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
    }
}

struct CreditSourceRow: View {
    let source: CreditSource
    let amount: Int

    var body: some View {
        LabeledContent(source.title, value: "\(amount)")
    }
}

struct AviHomeView: View {
    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore

    var body: some View {
        List {
            Section {
                AviCompanionView(
                    state: accountController.isSignedIn ? .storyDraft : .onboarding,
                    message: accountController.isSignedIn
                        ? "I can help explain credits, draft structure, previews, final export, and recovery paths."
                        : "Sign in first so project guidance, credits, drafts, and exports stay tied to your private account."
                )
            }

            Section("Next Step") {
                if accountController.isSignedIn {
                    NavigationLink {
                        CreateMomentView()
                            .navigationTitle("Create")
                    } label: {
                        Label("Create a memory video", systemImage: "plus.app")
                    }

                    NavigationLink {
                        ProjectsView()
                            .navigationTitle("Projects")
                    } label: {
                        Label(projectStore.projects.isEmpty ? "Review projects" : "Review \(projectStore.projects.count) projects", systemImage: "rectangle.stack")
                    }
                } else {
                    AuthActionButtons()
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }

            Section("Credits") {
                if accountController.isSignedIn {
                    CreditSourceRow(source: .proMonthly, amount: accountController.creditBalance.proMonthly)
                    CreditSourceRow(source: .promotional, amount: accountController.creditBalance.promotional)
                    CreditSourceRow(source: .purchased, amount: accountController.creditBalance.purchased)
                    LabeledContent("Spendable", value: "\(accountController.creditBalance.spendable)")
                } else {
                    Text("Credit details appear after Account AV sign-in.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Help") {
                NavigationLink {
                    AccountView()
                        .navigationTitle("Account")
                } label: {
                    Label("Account and support", systemImage: "person.crop.circle")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(MomentsBrand.ColorToken.appBackground)
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
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
    }
}

struct TemplateCard: View {
    let template: MomentTemplate
    let balance: MomentsCreditBalance

    private var canAfford: Bool {
        MomentsCreditGate.canAfford(template, balance: balance)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(template.title)
                    .font(.headline)
                Spacer()
                Text(template.duration)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MomentsBrand.ColorToken.primaryAccent)
            }

            Text(template.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(template.mediaRange, systemImage: "photo.on.rectangle.angled")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            HStack {
                Label("\(template.creditCost) credits", systemImage: "bolt.circle")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                NavigationLink(canAfford ? "Start" : "Add credits") {
                    DraftFlowView(template: template)
                }
                    .buttonStyle(.bordered)
                    .disabled(!canAfford)
            }
        }
        .padding(16)
        .background(MomentsBrand.ColorToken.elevatedSurface, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
        .opacity(canAfford ? 1 : 0.68)
    }
}

#Preview {
    RootView()
}
