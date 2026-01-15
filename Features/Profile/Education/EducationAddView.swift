//
//  EducationAddView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct EducationAddView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: EducationViewModel

    @State private var school = ""
    @State private var degree = ""
    @State private var field = ""
    @State private var startDate = "" // "2022-09-01"
    @State private var endDate = ""   // "2026-06-01"
    @State private var grade = ""
    @State private var desc = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Okul", text: $school)
                TextField("Derece (Lisans, YL)", text: $degree)
                TextField("Bölüm", text: $field)
                TextField("Başlangıç (YYYY-MM-DD)", text: $startDate)
                TextField("Bitiş (YYYY-MM-DD)", text: $endDate)
                TextField("Not/Ortalama", text: $grade)
                TextField("Açıklama", text: $desc)

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
                                    school: school,
                                    degree: degree.isEmpty ? nil : degree,
                                    field: field.isEmpty ? nil : field,
                                    startDate: startDate.isEmpty ? nil : startDate,
                                    endDate: endDate.isEmpty ? nil : endDate,
                                    grade: grade.isEmpty ? nil : grade,
                                    description: desc.isEmpty ? nil : desc
                                )
                                dismiss()
                            } catch {
                                self.error = error.localizedDescription
                            }
                        }
                    }
                    .disabled(school.isEmpty)
                }
            }
        }
    }
}
