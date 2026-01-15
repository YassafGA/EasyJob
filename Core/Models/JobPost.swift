import Foundation

struct JobPost: Codable, Identifiable {
    let id: UUID
    let company_id: UUID

    var title: String?
    var location: String?

    // DB’de NOT NULL olan eski alan (send etmesen bile decode’da gelebilir)
    var type: String?   // ✅ ekledik (eski şema ile uyum)

    var job_category: String?
    var seniority: String?
    var employment_type: String?
    var work_model: String?

    var salary_min: Int?
    var salary_max: Int?
    var currency: String?

    var description: String?
    var responsibilities: String?
    var requirements: String?
    var nice_to_have: String?
    var benefits: String?
    var tech_stack: String?

    // ✅ Date yerine String: Postgres date -> "YYYY-MM-DD"
    var application_deadline: String?

    // ✅ timestamptz decode sorunlarını bitirmek için string
    var created_at: String?
    var updated_at: String?
}
