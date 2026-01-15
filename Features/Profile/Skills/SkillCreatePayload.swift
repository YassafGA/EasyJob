import Foundation
import Supabase

struct SkillCreatePayload: Encodable {
    let profile_id: String
    let skill: String
    let level: String?
}

@MainActor
final class SkillViewModel: ObservableObject {
    @Published var items: [ProfileSkill] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    func fetch() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let uid = try await client.auth.session.user.id.uuidString

            let items: [ProfileSkill] = try await client
                .from("profile_skills")
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

    func add(skill: String, level: String?) async throws {
        let uid = try await client.auth.session.user.id.uuidString

        let payload = SkillCreatePayload(
            profile_id: uid,
            skill: skill,
            level: level?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : level
        )

        _ = try await client.from("profile_skills").insert(payload).execute()
        await fetch()
    }

    func delete(id: UUID) async throws {
        _ = try await client
            .from("profile_skills")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        await fetch()
    }
}
