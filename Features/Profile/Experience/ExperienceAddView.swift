//
//  ExperienceAddView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct ExperienceAddView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ExperienceViewModel

    @State private var company = ""
    @State private var position = ""
    @State private var employmentType = "full-time"
    @State private var location = ""
    @State private var startDate = "" // YYYY-MM-DD
    @State private var endDate = ""   // YYYY-MM-DD
    @State private var isCurrent = false
    @State private var desc = ""
    @State private var techStack = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Temel") {
                    TextField("Şirket", text: $company)
                    TextField("Pozisyon", text: $position)

                    Picker("Çalışma Türü", selection: $employmentType) {
                        Text("Full-time").tag("full-time")
                        Text("Part-time").tag("part-time")
                        Text("Contract").tag("contract")
                        Text("Intern").tag("intern")
                    }

                    TextField("Lokasyon", text: $location)
                }

                Section("Tarih") {
                    Toggle("Hâlen çalışıyorum", isOn: $isCurrent)
                    TextField("Başlangıç (YYYY-MM-DD)", text: $startDate)
                    if !isCurrent {
                        TextField("Bitiş (YYYY-MM-DD)", text: $endDate)
                    }
                }

                Section("Detay") {
                    TextField("Tech Stack (örn: Swift, SwiftUI, REST)", text: $techStack)
                    TextField("Açıklama", text: $desc)
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
                                try await vm.add(
                                    company: company,
                                    position: position,
                                    employmentType: employmentType.isEmpty ? nil : employmentType,
                                    location: location.isEmpty ? nil : location,
                                    startDate: startDate.isEmpty ? nil : startDate,
                                    endDate: endDate.isEmpty ? nil : endDate,
                                    isCurrent: isCurrent,
                                    description: desc.isEmpty ? nil : desc,
                                    techStack: techStack.isEmpty ? nil : techStack
                                )
                                dismiss()
                            } catch {
                                self.error = error.localizedDescription
                            }
                        }
                    }
                    .disabled(company.isEmpty || position.isEmpty)
                }
            }
        }
    }
}
