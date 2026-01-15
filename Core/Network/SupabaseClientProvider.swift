import Foundation
import Supabase

final class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()

    let client: SupabaseClient

    private init() {
        // TODO: Buraya kendi Supabase bilgilerini gir
        let supabaseURL = URL(string: "https://huhggjeoglfloikjgzek.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1aGdnamVvZ2xmbG9pa2pnemVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY2NjYzODIsImV4cCI6MjA4MjI0MjM4Mn0.A7qNEwAmO6UsjHdHFo1oIss1EyfLT61Yk8Z2_-_0BpQ"

        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}
