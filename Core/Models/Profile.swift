import Foundation

enum UserRole: String, Codable {
    case candidate
    case company
}

struct Profile: Codable, Identifiable {
    let id: UUID
    var role: UserRole

    var full_name: String?
    var profession: String?
    var email: String?
    var phone: String?
    var title: String?

    var github_url: String?
    var portfolio_url: String?
    var linkedin_url: String?

    var company_name: String?
    var company_website: String?
    var company_sector: String?
    var company_size: String?
    var company_location: String?
    var company_about: String?

    var updated_at: Date?
}
