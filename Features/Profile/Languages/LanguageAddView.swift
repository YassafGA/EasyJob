//
//  LanguageAddView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct LanguageAddView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: LanguageViewModel

    @State private var language = ""
    @State private var level = "B2"
    @State private var error: String?

    private let levels = ["A1","A2","B1","B2","C1","C2","Native"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Dil (örn: English)", text: $language)

                Picker("Seviye", selection: $level) {
                    ForEach(levels, id: \.self) { Text($0).tag($0) }
                }

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
                                try await vm.add(language: language, level: level)
                                dismiss()
                            } catch {
                                self.error = error.localizedDescription
                            }
                        }
                    }
                    .disabled(language.isEmpty)
                }
            }
        }
    }
}
