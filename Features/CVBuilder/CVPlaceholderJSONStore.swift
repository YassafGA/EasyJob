import Foundation
import Supabase

final class CVPlaceholderJSONStore {
    private let client = SupabaseClientProvider.shared.client

    /// DOCX template içinde kullanılacak placeholder'ların JSON temsili
    /// Template placeholders örnekleri:
    /// {{name}}, {{email}}, {{phoneNumber}}, {{linkedInURL}}, {{gitHubURL}}, {{portfolioURL}},
    /// {{workExperience}}, {{education}}, {{languages}}, {{skills}}
    struct PlaceholderJSON: Codable {
        let name: String
        let profession: String
        let email: String
        let phoneNumber: String
        let linkedInURL: String
        let gitHubURL: String
        let portfolioURL: String

        let workExperience: String
        let education: String
        let languages: String
        let skills: String
    }

    /// DB -> JSON (Documents/cv_placeholders.json)
    func exportPlaceholdersJSON(fileName: String = "cv_placeholders.json") async throws -> URL {
        let session = try await client.auth.session
        let uid = session.user.id.uuidString

        // 1) Profile
        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: uid)
            .single()
            .execute()
            .value

        // 2) Education
        let education: [ProfileEducation] = try await client
            .from("profile_education")
            .select()
            .eq("profile_id", value: uid)
            .order("start_date", ascending: false)
            .execute()
            .value

        // 3) Experience
        let experience: [ProfileExperience] = try await client
            .from("profile_experience")
            .select()
            .eq("profile_id", value: uid)
            .order("start_date", ascending: false)
            .execute()
            .value

        // 4) Languages
        let languages: [ProfileLanguage] = try await client
            .from("profile_languages")
            .select()
            .eq("profile_id", value: uid)
            .order("created_at", ascending: false)
            .execute()
            .value

        // 5) Skills
        // (Eğer tabloda skill seviyen yoksa, modelde level optional kalabilir.)
        let skills: [ProfileSkill] = try await client
            .from("profile_skills")
            .select()
            .eq("profile_id", value: uid)
            .order("created_at", ascending: false)
            .execute()
            .value

        // ---------- TEXT BUILDERS (DOCX için tek string) ----------
        let expText = buildExperienceText(experience)
        let eduText = buildEducationText(education)
        let langText = buildLanguagesText(languages)
        let skillsText = buildSkillsText(skills)

        // ---------- PLACEHOLDER JSON ----------
        let payload = PlaceholderJSON(
            name: profile.full_name ?? "",
            profession: profile.profession ?? "",
            email: profile.email ?? "",
            phoneNumber: profile.phone ?? "",
            linkedInURL: profile.linkedin_url ?? "",
            gitHubURL: profile.github_url ?? "",
            portfolioURL: profile.portfolio_url ?? "",
            workExperience: expText,
            education: eduText,
            languages: langText,
            skills: skillsText
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data: Data = try encoder.encode(payload)

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent(fileName)

        // ✅ Atomic yazma (context hatası yaşamamak için açık tip)
        try data.write(to: url, options: Data.WritingOptions.atomic)

        return url
    }

    // MARK: - Helpers (String Builders)

    private func buildExperienceText(_ list: [ProfileExperience]) -> String {
        guard !list.isEmpty else { return "" }

        return list.map { x in
            let start = (x.start_date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let end = x.is_current ? "Present" : ((x.end_date ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
            let range = [start, end].filter { !$0.isEmpty }.joined(separator: " - ")

            let typePart = (x.employment_type?.isEmpty == false) ? " • \(x.employment_type!)" : ""
            let locPart = (x.location?.isEmpty == false) ? " • \(x.location!)" : ""
            let techPart = (x.tech_stack?.isEmpty == false) ? "\nTech: \(x.tech_stack!)" : ""
            let descPart = (x.description?.isEmpty == false) ? "\n\(x.description!)" : ""

            // Örnek çıktı:
            // • iOS Developer @ ABC (2024-01-01 - Present) • Full-time • Remote
            // Tech: Swift, SwiftUI
            // Açıklama...
            return """
            • \(x.position) @ \(x.company)\(range.isEmpty ? "" : " (\(range))")\(typePart)\(locPart)\(techPart)\(descPart)
            """
        }
        .joined(separator: "\n\n")
    }

    private func buildEducationText(_ list: [ProfileEducation]) -> String {
        guard !list.isEmpty else { return "" }

        return list.map { e in
            let start = (e.start_date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let end = (e.end_date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let range = [start, end].filter { !$0.isEmpty }.joined(separator: " - ")

            let degreePart = (e.degree?.isEmpty == false) ? " • \(e.degree!)" : ""
            let fieldPart = (e.field?.isEmpty == false) ? " • \(e.field!)" : ""
            let gradePart = (e.grade?.isEmpty == false) ? "\nGPA/Grade: \(e.grade!)" : ""
            let descPart = (e.description?.isEmpty == false) ? "\n\(e.description!)" : ""

            // • University X • BSc • Software Engineering (2020-09-01 - 2024-06-01)
            // GPA...
            // desc...
            return """
            • \(e.school)\(degreePart)\(fieldPart)\(range.isEmpty ? "" : " (\(range))")\(gradePart)\(descPart)
            """
        }
        .joined(separator: "\n\n")
    }

    private func buildLanguagesText(_ list: [ProfileLanguage]) -> String {
        guard !list.isEmpty else { return "" }
        return list.map { "• \($0.language) - \($0.level)" }.joined(separator: "\n")
    }

    private func buildSkillsText(_ list: [ProfileSkill]) -> String {
        guard !list.isEmpty else { return "" }
        return list.map { s in
            if let lvl = s.level, !lvl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "• \(s.skill) (\(lvl))"
            }
            return "• \(s.skill)"
        }
        .joined(separator: "\n")
    }
}
