import Foundation
import Supabase

@MainActor
final class ApplicantsViewModel: ObservableObject {
    @Published var applications: [JobApplication] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    func fetchApplicants(for jobId: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let apps: [JobApplication] = try await client
                .from("applications")
                .select()
                .eq("job_id", value: jobId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value

            self.applications = apps
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    struct ApplicationStatusUpdatePayload: Encodable {
        let status: String
    }

    func updateStatus(applicationId: UUID, newStatus: String, jobId: UUID) async {
        do {
            let payload = ApplicationStatusUpdatePayload(status: newStatus)
            _ = try await client
                .from("applications")
                .update(payload)
                .eq("id", value: applicationId.uuidString)
                .execute()

            await fetchApplicants(for: jobId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
