import Foundation
import Supabase

final class CVJSONStore {
    private let client = SupabaseClientProvider.shared.client

    func exportCVJSONFromDatabase(fileName: String = "user_cv_data.json") async throws -> URL {
        let session = try await client.auth.session
        let userId = session.user.id.uuidString

        // 1) Profile
        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value

        // 2) Education
        let education: [ProfileEducation] = try await client
            .from("profile_education")
            .select()
            .eq("profile_id", value: userId)
            .order("start_date", ascending: false)
            .execute()
            .value

        // 3) Experience
        let experience: [ProfileExperience] = try await client
            .from("profile_experience")
            .select()
            .eq("profile_id", value: userId)
            .order("start_date", ascending: false)
            .execute()
            .value

        // 4) Languages
        let languages: [ProfileLanguage] = try await client
            .from("profile_languages")
            .select()
            .eq("profile_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value

        // 5) CVData oluştur (fromProfile yok!)
        let cvEducation: [CVData.CVEducation] = education.map { e in
            CVData.CVEducation(
                school: e.school,
                degree: e.degree,
                field: e.field,
                start: Self.formatDate(e.start_date),
                end: Self.formatDate(e.end_date),
                grade: e.grade,
                description: e.description
            )
        }

        let cvExperience: [CVData.CVExperience] = experience.map { x in
            CVData.CVExperience(
                company: x.company,
                position: x.position,
                employmentType: x.employment_type,
                location: x.location,
                start: Self.formatDate(x.start_date),
                end: Self.formatDate(x.end_date),
                isCurrent: x.is_current,
                description: x.description,
                techStack: x.tech_stack
            )
        }

        let cvLanguages: [CVData.CVLanguage] = languages.map { l in
            CVData.CVLanguage(language: l.language, level: l.level)
        }

        let cvData = CVData(
            name: profile.full_name ?? "",
            profession: profile.profession ?? "",
            email: profile.email ?? "",
            phone: profile.phone ?? "",
            github: profile.github_url ?? "",
            portfolio: profile.portfolio_url ?? "",
            linkedin: profile.linkedin_url ?? "",
            education: cvEducation,
            experience: cvExperience,
            languages: cvLanguages
        )

        // 6) JSON encode (burada jsonData kesinlikle Data)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData: Data = try encoder.encode(cvData)

        // 7) Documents’a yaz (atomic context hatasını kesin çözüyoruz)
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent(fileName)

        try jsonData.write(to: url, options: Data.WritingOptions.atomic)

        return url
    }

    func loadCVJSON(fileName: String = "user_cv_data.json") throws -> CVData {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent(fileName)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(CVData.self, from: data)
    }

    private static func formatDate(_ d: Date?) -> String? {
        guard let d else { return nil }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }

    private static func formatDate(_ d: String?) -> String? {
        guard let d, !d.isEmpty else { return nil }
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: d) {
            return formatDate(date)
        }
        return d
    }
}
