import Foundation
import Supabase

@MainActor
final class CompanyApplicationsViewModel: ObservableObject {
    struct CompanyPostSummary: Codable, Identifiable {
        let id: UUID
        let title: String?
        let location: String?
    }

    struct CandidateProfile: Codable {
        let full_name: String?
        let email: String?
        let phone: String?
        let title: String?
        let linkedin_url: String?
        let portfolio_url: String?
    }

    struct CompanyApplicationRow: Codable, Identifiable {
        let id: UUID
        let job_id: UUID
        let candidate_id: UUID
        var status: String
        var cover_letter: String?
        var cv_url: String?
        var created_at: String?
        let candidate: CandidateProfile?
    }

    struct CompanyJobGroup: Identifiable {
        let id: UUID
        let title: String?
        let location: String?
        let applications: [CompanyApplicationRow]
    }

    @Published var groups: [CompanyJobGroup] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client
    private var lastPostIds: [String] = []

    func fetchAll() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let companyId = try await client.auth.session.user.id.uuidString

            let posts: [CompanyPostSummary] = try await client
                .from("job_posts")
                .select("id, title, location")
                .eq("company_id", value: companyId)
                .order("created_at", ascending: false)
                .execute()
                .value

            let postIds = posts.map { $0.id.uuidString }
            lastPostIds = postIds
            guard !postIds.isEmpty else {
                groups = []
                return
            }

            let apps: [CompanyApplicationRow] = try await client
                .from("applications")
                .select("id, job_id, candidate_id, status, cover_letter, cv_url, created_at, candidate:profiles(full_name, email, phone, title, linkedin_url, portfolio_url)")
                .in("job_id", values: postIds)
                .order("created_at", ascending: false)
                .execute()
                .value

            let grouped = Dictionary(grouping: apps, by: { $0.job_id })
            groups = posts.map { post in
                CompanyJobGroup(
                    id: post.id,
                    title: post.title,
                    location: post.location,
                    applications: grouped[post.id] ?? []
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    struct ApplicationStatusUpdatePayload: Encodable {
        let status: String
    }

    func updateStatus(applicationId: UUID, newStatus: String) async throws {
        let payload = ApplicationStatusUpdatePayload(status: newStatus)
        _ = try await client
            .from("applications")
            .update(payload)
            .eq("id", value: applicationId.uuidString)
            .execute()
    }

    func clearArchived() async throws {
        guard !lastPostIds.isEmpty else { return }
        _ = try await client
            .from("applications")
            .delete()
            .in("job_id", values: lastPostIds)
            .in("status", values: ["accepted", "rejected"])
            .execute()
    }

    func deleteApplication(applicationId: UUID) async throws {
        _ = try await client
            .from("applications")
            .delete()
            .eq("id", value: applicationId.uuidString)
            .execute()
    }
}
