import Foundation

struct ProfileExperience: Codable, Identifiable {
    let id: UUID
    let profile_id: UUID

    var company: String
    var position: String

    var employment_type: String?
    var location: String?

    // ✅ Date yerine String
    var start_date: String?
    var end_date: String?

    var is_current: Bool
    var description: String?
    var tech_stack: String?

    var created_at: String?
}
