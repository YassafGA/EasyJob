import Foundation
import Supabase

@MainActor
final class SessionStore: ObservableObject {

    enum AppState {
        case loading
        case unauthenticated
        case authenticated(role: UserRole)
    }

    @Published var state: AppState = .loading
    @Published var profile: Profile?

    private let client = SupabaseClientProvider.shared.client

    func bootstrap() async {
        do {
            _ = try await client.auth.session
            try await loadProfileAndRoute()
        } catch {
            state = .unauthenticated
        }
    }

    func loadProfileAndRoute() async throws {
        let session = try await client.auth.session
        let userId = session.user.id

        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        self.profile = profile
        self.state = .authenticated(role: profile.role)
    }

    func signOut() async {
        await AuthService().signOut()
        profile = nil
        state = .unauthenticated
    }
}
