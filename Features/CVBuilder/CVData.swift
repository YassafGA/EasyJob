import Foundation

struct CVData: Codable {
    var name: String
    var profession: String
    var email: String
    var phone: String
    var github: String
    var portfolio: String
    var linkedin: String

    var education: [CVEducation]
    var experience: [CVExperience]
    var languages: [CVLanguage]

    struct CVEducation: Codable {
        var school: String
        var degree: String?
        var field: String?
        var start: String?
        var end: String?
        var grade: String?
        var description: String?
    }

    struct CVExperience: Codable {
        var company: String
        var position: String
        var employmentType: String?
        var location: String?
        var start: String?
        var end: String?
        var isCurrent: Bool
        var description: String?
        var techStack: String?
    }

    struct CVLanguage: Codable {
        var language: String
        var level: String
    }

    func toPlaceholders() -> [String: String] {
        [
            "name": name,
            "profession": profession,
            "email": email,
            "phone": phone,
            "github": github,
            "portfolio": portfolio,
            "linkedin": linkedin
        ]
    }
}
