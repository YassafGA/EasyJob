import Foundation
import Supabase

@MainActor
final class CandidateJobViewModel: ObservableObject {
    @Published var jobs: [JobPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    struct JobFilters {
        var query: String = ""
        var category: String? = nil
        var seniority: String? = nil
        var workModel: String? = nil
    }

    func fetchJobs(filters: JobFilters = .init()) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var q = client.from("job_posts").select()

            if !filters.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Basit LIKE: title ilanda aransın (Supabase PostgREST için ilike)
                // supabase-swift'te ilike mevcut
                q = q.ilike("title", pattern: "%\(filters.query)%")
            }
            if let c = filters.category, !c.isEmpty {
                q = q.eq("job_category", value: c)
            }
            if let s = filters.seniority, !s.isEmpty {
                q = q.eq("seniority", value: s)
            }
            if let w = filters.workModel, !w.isEmpty {
                q = q.eq("work_model", value: w)
            }

            let jobs: [JobPost] = try await q
                .order("created_at", ascending: false)
                .execute()
                .value

            self.jobs = jobs
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func apply(jobId: UUID, coverLetter: String?, cvFileURL: URL?) async throws {
        let session = try await client.auth.session
        let candidateId = session.user.id

        struct ApplyPayload: Encodable {
            let job_id: String
            let candidate_id: String
            let status: String
            let cover_letter: String?
            let cv_url: String?
        }

        let cvURL = try await uploadCVIfNeeded(fileURL: cvFileURL, candidateId: candidateId.uuidString, jobId: jobId.uuidString)

        let payload = ApplyPayload(
            job_id: jobId.uuidString,
            candidate_id: candidateId.uuidString,
            status: "submitted",
            cover_letter: coverLetter,
            cv_url: cvURL
        )

        _ = try await client.from("applications").insert(payload).execute()
    }

    private func uploadCVIfNeeded(fileURL: URL?, candidateId: String, jobId: String) async throws -> String? {
        guard let fileURL else { return nil }

        let canAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if canAccess { fileURL.stopAccessingSecurityScopedResource() }
        }

        let data = try Data(contentsOf: fileURL)
        let ext = fileURL.pathExtension.lowercased()
        let contentType: String
        switch ext {
        case "pdf":
            contentType = "application/pdf"
        case "docx":
            contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default:
            throw NSError(domain: "CVUpload", code: 415, userInfo: [NSLocalizedDescriptionKey: "Sadece PDF veya DOCX kabul edilir."])
        }

        let bucket = client.storage.from("cv_files")
        let fileName = "\(UUID().uuidString).\(ext)"
        let path = "\(candidateId)/\(jobId)/\(fileName)"

        try await bucket.upload(
            path: path,
            file: data,
            options: FileOptions(contentType: contentType, upsert: false)
        )

        let publicURL = try bucket.getPublicURL(path: path)
        return publicURL.absoluteString
    }
}
