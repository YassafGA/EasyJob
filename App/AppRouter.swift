import SwiftUI

struct AppRouter: View {
    @StateObject private var sessionStore = SessionStore()

    var body: some View {
        Group {
            switch sessionStore.state {
            case .loading:
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Yükleniyor...")
                }

            case .unauthenticated:
                AuthRootView()
                    .environmentObject(sessionStore)

            case .authenticated(let role):
                if role == .company {
                    CompanyTabView()
                        .environmentObject(sessionStore)
                } else {
                    CandidateTabView()
                        .environmentObject(sessionStore)
                }
            }
        }
        .task { await sessionStore.bootstrap() }
    }
}
