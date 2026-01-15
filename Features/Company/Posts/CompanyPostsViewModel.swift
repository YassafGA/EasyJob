import Foundation
import Supabase

@MainActor
final class CompanyPostsViewModel: ObservableObject {
    @Published var posts: [JobPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    // MARK: - Fetch My Posts
    func fetchMyPosts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let companyId = try await client.auth.session.user.id.uuidString

            let posts: [JobPost] = try await client
                .from("job_posts")
                .select("id, company_id, title, location, type, job_category, seniority, employment_type, work_model, salary_min, salary_max, currency, description, responsibilities, requirements, nice_to_have, benefits, tech_stack, application_deadline, created_at, updated_at")
                .eq("company_id", value: companyId)
                .order("created_at", ascending: false)
                .execute()
                .value


            self.posts = posts
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Post (Detaylı)
    private struct JobPostCreatePayload: Encodable {
        let company_id: String
        let title: String?
        let location: String?

        let job_category: String?
        let seniority: String?
        let employment_type: String?
        let work_model: String?

        let salary_min: Int?
        let salary_max: Int?
        let currency: String?

        let description: String?
        let responsibilities: String?
        let requirements: String?
        let nice_to_have: String?
        let benefits: String?
        let tech_stack: String?

        let application_deadline: String? // "YYYY-MM-DD"
    }

    func createPost(
        title: String?,
        location: String?,
        jobCategory: String?,
        seniority: String?,
        employmentType: String?,
        workModel: String?,
        salaryMin: Int?,
        salaryMax: Int?,
        currency: String?,
        description: String?,
        responsibilities: String?,
        requirements: String?,
        niceToHave: String?,
        benefits: String?,
        techStack: String?,
        applicationDeadline: String?
    ) async throws {

        let companyId = try await client.auth.session.user.id.uuidString

        let payload = JobPostCreatePayload(
            company_id: companyId,
            title: title,
            location: location,
            job_category: jobCategory,
            seniority: seniority,
            employment_type: employmentType,
            work_model: workModel,
            salary_min: salaryMin,
            salary_max: salaryMax,
            currency: currency,
            description: description,
            responsibilities: responsibilities,
            requirements: requirements,
            nice_to_have: niceToHave,
            benefits: benefits,
            tech_stack: techStack,
            application_deadline: applicationDeadline
        )

        _ = try await client
            .from("job_posts")
            .insert(payload)
            .execute()
    }

    // MARK: - Delete Post
    func deletePost(postId: UUID) async throws {
        _ = try await client
            .from("job_posts")
            .delete()
            .eq("id", value: postId.uuidString)
            .execute()
    }
}
