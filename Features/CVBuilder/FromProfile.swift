//
//  fff.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import Foundation

extension CVData {
    static func fromProfile(
        _ p: Profile,
        education: [ProfileEducation] = [],
        experience: [ProfileExperience] = [],
        languages: [ProfileLanguage] = []
    ) -> CVData {

        let edu = education.map {
            CVEducation(
                school: $0.school,
                degree: $0.degree,
                field: $0.field,
                start: formatDate($0.start_date),
                end: formatDate($0.end_date),
                grade: $0.grade,
                description: $0.description
            )
        }

        let exp = experience.map {
            CVExperience(
                company: $0.company,
                position: $0.position,
                employmentType: $0.employment_type,
                location: $0.location,
                start: formatDate($0.start_date),
                end: formatDate($0.end_date),
                isCurrent: $0.is_current,
                description: $0.description,
                techStack: $0.tech_stack
            )
        }

        let langs = languages.map {
            CVLanguage(language: $0.language, level: $0.level)
        }

        return CVData(
            name: p.full_name ?? "",
            profession: p.profession ?? "",
            email: p.email ?? "",
            phone: p.phone ?? "",
            github: p.github_url ?? "",
            portfolio: p.portfolio_url ?? "",
            linkedin: p.linkedin_url ?? "",
            education: edu,
            experience: exp,
            languages: langs
        )
    }

    private static func formatDate(_ d: Date?) -> String? {
        guard let d else { return nil }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }
}
