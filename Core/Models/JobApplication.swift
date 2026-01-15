import Foundation

struct JobApplication: Codable, Identifiable {
    let id: UUID
    let job_id: UUID
    let candidate_id: UUID

    var status: String
    var cover_letter: String?
    var cv_url: String?

    var created_at: Date?
}
