import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""

    @Published var role: UserRole = .candidate
    @Published var companyName = ""

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client
    private let auth = AuthService()

    func login(sessionStore: SessionStore) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await auth.signIn(email: email, password: password)
            try await sessionStore.loadProfileAndRoute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(sessionStore: SessionStore) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await auth.signUp(email: email, password: password)

            // Bazı Supabase ayarlarında signUp sonrası session hemen oluşmayabilir.
            // Çoğu tez demosunda email confirmation kapatılır ve session gelir.
            let session = try await client.auth.session
            let userId = session.user.id

            var payload: [String: AnyJSON] = [
                "id": .string(userId.uuidString),
                "role": .string(role.rawValue),
                "email": .string(email),
                "full_name": .string(fullName)
            ]

            if role == .company {
                payload["company_name"] = .string(companyName)
            }

            _ = try await client
                .from("profiles")
                .insert(payload)
                .execute()

            try await sessionStore.loadProfileAndRoute()

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
