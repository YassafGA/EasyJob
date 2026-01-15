//
//  LanguageCreatePayload.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import Foundation
import Supabase

struct LanguageCreatePayload: Encodable {
    let profile_id: String
    let language: String
    let level: String
}

@MainActor
final class LanguageViewModel: ObservableObject {
    @Published var items: [ProfileLanguage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    func fetch() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let uid = try await client.auth.session.user.id.uuidString

            let items: [ProfileLanguage] = try await client
                .from("profile_languages")
                .select()
                .eq("profile_id", value: uid)
                .order("created_at", ascending: false)
                .execute()
                .value

            self.items = items
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func add(language: String, level: String) async throws {
        let uid = try await client.auth.session.user.id.uuidString

        let payload = LanguageCreatePayload(
            profile_id: uid,
            language: language,
            level: level
        )

        _ = try await client.from("profile_languages").insert(payload).execute()
        await fetch()
    }

    func delete(id: UUID) async throws {
        _ = try await client
            .from("profile_languages")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        await fetch()
    }
}
