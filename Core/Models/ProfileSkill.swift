import Foundation

struct ProfileSkill: Codable, Identifiable {
    let id: UUID
    let profile_id: UUID

    var skill: String
    var level: String?

    var created_at: String?
}
