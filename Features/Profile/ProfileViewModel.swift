import Foundation
import Supabase

struct ProfileUpdatePayload: Encodable {
    let full_name: String
    let profession: String
    let phone: String
    let title: String
    let github_url: String
    let portfolio_url: String
    let linkedin_url: String
    let company_name: String?
    let company_website: String?
    let company_sector: String?
    let company_size: String?
    let company_location: String?
    let company_about: String?
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var profession = ""
    @Published var phone = ""
    @Published var title = ""

    @Published var githubURL = ""
    @Published var portfolioURL = ""
    @Published var linkedinURL = ""

    @Published var companyName = ""
    @Published var companyWebsite = ""
    @Published var companySector = ""
    @Published var companySize = ""
    @Published var companyLocation = ""
    @Published var companyAbout = ""

    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let client = SupabaseClientProvider.shared.client

    func load(from profile: Profile?) {
        fullName = profile?.full_name ?? ""
        profession = profile?.profession ?? ""
        phone = profile?.phone ?? ""
        title = profile?.title ?? ""

        githubURL = profile?.github_url ?? ""
        portfolioURL = profile?.portfolio_url ?? ""
        linkedinURL = profile?.linkedin_url ?? ""

        companyName = profile?.company_name ?? ""
        companyWebsite = profile?.company_website ?? ""
        companySector = profile?.company_sector ?? ""
        companySize = profile?.company_size ?? ""
        companyLocation = profile?.company_location ?? ""
        companyAbout = profile?.company_about ?? ""
    }

    func save(role: UserRole, profileId: UUID, sessionStore: SessionStore) async {
        isSaving = true
        errorMessage = nil
        successMessage = nil
        defer { isSaving = false }

        do {
            let payload = ProfileUpdatePayload(
                full_name: fullName,
                profession: profession,
                phone: phone,
                title: title,
                github_url: githubURL,
                portfolio_url: portfolioURL,
                linkedin_url: linkedinURL,
                company_name: role == .company ? companyName : nil,
                company_website: role == .company ? emptyToNil(companyWebsite) : nil,
                company_sector: role == .company ? emptyToNil(companySector) : nil,
                company_size: role == .company ? emptyToNil(companySize) : nil,
                company_location: role == .company ? emptyToNil(companyLocation) : nil,
                company_about: role == .company ? emptyToNil(companyAbout) : nil
            )

            _ = try await client
                .from("profiles")
                .update(payload)
                .eq("id", value: profileId.uuidString)
                .execute()

            try await sessionStore.loadProfileAndRoute()
            successMessage = "Kaydedildi ✅"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func emptyToNil(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
