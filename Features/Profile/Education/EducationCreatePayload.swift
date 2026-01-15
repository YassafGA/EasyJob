//
//  EducationCreatePayload.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import Foundation
import Supabase

struct EducationCreatePayload: Encodable {
    let profile_id: String
    let school: String
    let degree: String?
    let field: String?
    let start_date: String?
    let end_date: String?
    let grade: String?
    let description: String?
}

@MainActor
final class EducationViewModel: ObservableObject {
    @Published var items: [ProfileEducation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    func fetch() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await client.auth.session
            let uid = session.user.id.uuidString

            let items: [ProfileEducation] = try await client
                .from("profile_education")
                .select()
                .eq("profile_id", value: uid)
                .execute()
                .value

            self.items = items
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func add(
        school: String,
        degree: String?,
        field: String?,
        startDate: String?,
        endDate: String?,
        grade: String?,
        description: String?
    ) async throws {
        let session = try await client.auth.session
        let uid = session.user.id.uuidString

        let payload = EducationCreatePayload(
            profile_id: uid,
            school: school,
            degree: degree,
            field: field,
            start_date: startDate,
            end_date: endDate,
            grade: grade,
            description: description
        )

        _ = try await client.from("profile_education").insert(payload).execute()
        await fetch()
    }

    func delete(id: UUID) async throws {
        _ = try await client
            .from("profile_education")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        await fetch()
    }
}
