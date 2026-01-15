import Foundation
import Supabase

final class AuthService {
    private let client = SupabaseClientProvider.shared.client

    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async {
        do { try await client.auth.signOut() } catch { }
    }
}
