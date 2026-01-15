import Foundation

struct ProfileEducation: Codable, Identifiable {
    let id: UUID
    let profile_id: UUID

    var school: String
    var degree: String?
    var field: String?

    // ✅ Date yerine String (Postgres date genelde "YYYY-MM-DD" gelir)
    var start_date: String?
    var end_date: String?

    var grade: String?
    var description: String?

    var created_at: String?
}
