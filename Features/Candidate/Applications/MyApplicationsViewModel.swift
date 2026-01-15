import Foundation
import Supabase

@MainActor
final class MyApplicationsViewModel: ObservableObject {
    @Published var apps: [MyApplicationRow] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    func fetchMyApplications() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let myId = try await client.auth.session.user.id.uuidString

            let apps: [MyApplicationRow] = try await client
                .from("v_my_applications")
                .select()
                .eq("candidate_id", value: myId)
                .order("created_at", ascending: false)
                .execute()
                .value

            self.apps = apps
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func withdraw(applicationId: UUID) async throws {
        _ = try await client
            .from("applications")
            .delete()
            .eq("id", value: applicationId.uuidString)
            .execute()
    }
}
