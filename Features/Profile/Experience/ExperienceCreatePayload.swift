//
//  ExperienceCreatePayload.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import Foundation
import Supabase

struct ExperienceCreatePayload: Encodable {
    let profile_id: String
    let company: String
    let position: String
    let employment_type: String?
    let location: String?
    let start_date: String?
    let end_date: String?
    let is_current: Bool
    let description: String?
    let tech_stack: String?
}

@MainActor
final class ExperienceViewModel: ObservableObject {
    @Published var items: [ProfileExperience] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    func fetch() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let uid = try await client.auth.session.user.id.uuidString

            let items: [ProfileExperience] = try await client
                .from("profile_experience")
                .select()
                .eq("profile_id", value: uid)
                .order("start_date", ascending: false)
                .execute()
                .value

            self.items = items
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func add(
        company: String,
        position: String,
        employmentType: String?,
        location: String?,
        startDate: String?,
        endDate: String?,
        isCurrent: Bool,
        description: String?,
        techStack: String?
    ) async throws {
        let uid = try await client.auth.session.user.id.uuidString

        let payload = ExperienceCreatePayload(
            profile_id: uid,
            company: company,
            position: position,
            employment_type: employmentType,
            location: location,
            start_date: startDate,
            end_date: isCurrent ? nil : endDate,
            is_current: isCurrent,
            description: description,
            tech_stack: techStack
        )

        _ = try await client.from("profile_experience").insert(payload).execute()
        await fetch()
    }

    func delete(id: UUID) async throws {
        _ = try await client
            .from("profile_experience")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        await fetch()
    }
}
