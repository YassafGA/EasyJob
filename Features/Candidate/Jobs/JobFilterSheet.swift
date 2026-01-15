//
//  JobFilterSheet.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct JobFilterSheet: View {
    @Environment(\.dismiss) var dismiss

    @Binding var category: String
    @Binding var seniority: String
    @Binding var workModel: String

    private let categories = ["", "Software","Design","Data","Product","QA","DevOps","Mobile","Other"]
    private let seniorities = ["", "Intern","Junior","Mid","Senior","Lead"]
    private let workModels = ["", "Remote","Hybrid","Onsite"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Kategori", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0.isEmpty ? "Hepsi" : $0).tag($0) }
                    }
                    Picker("Seviye", selection: $seniority) {
                        ForEach(seniorities, id: \.self) { Text($0.isEmpty ? "Hepsi" : $0).tag($0) }
                    }
                    Picker("Çalışma Modeli", selection: $workModel) {
                        ForEach(workModels, id: \.self) { Text($0.isEmpty ? "Hepsi" : $0).tag($0) }
                    }
                } header: {
                    Label("Filtreler", systemImage: "slider.horizontal.3")
                }

                Section {
                    Button("Filtreleri Sıfırla", role: .destructive) {
                        category = ""
                        seniority = ""
                        workModel = ""
                    }
                }
            }
            .navigationTitle("Filtreler")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uygula") { dismiss() }
                }
            }
        }
    }
}
