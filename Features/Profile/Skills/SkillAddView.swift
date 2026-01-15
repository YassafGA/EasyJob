import SwiftUI

struct SkillAddView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: SkillViewModel

    @State private var skill = ""
    @State private var level = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Yetenek (örn: Swift)", text: $skill)
                TextField("Seviye (opsiyonel)", text: $level)

                if let error { Text(error).foregroundStyle(.red) }
            }
            .navigationTitle("Ekle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        Task {
                            do {
                                let trimmed = level.trimmingCharacters(in: .whitespacesAndNewlines)
                                try await vm.add(skill: skill, level: trimmed.isEmpty ? nil : trimmed)
                                dismiss()
                            } catch {
                                self.error = error.localizedDescription
                            }
                        }
                    }
                    .disabled(skill.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
