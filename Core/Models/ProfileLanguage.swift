import Foundation

struct ProfileLanguage: Codable, Identifiable {
    let id: UUID
    let profile_id: UUID

    var language: String
    var level: String

    var created_at: String?
}
