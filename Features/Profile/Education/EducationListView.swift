//
//  EducationListView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct EducationListView: View {
    @StateObject private var vm = EducationViewModel()
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(vm.items) { e in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(e.school).font(.headline)
                        if let degree = e.degree { Text(degree).foregroundStyle(.secondary) }
                        if let field = e.field { Text(field).foregroundStyle(.secondary) }
                    }
                    Spacer()
                    Button(role: .destructive) {
                        Task { try? await vm.delete(id: e.id) }
                    } label: {
                        Text("Sil")
                    }
                    .buttonStyle(.borderless)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { try? await vm.delete(id: e.id) }
                    } label: {
                        Text("Sil")
                    }
                }
            }
            .onDelete { indexSet in
                Task {
                    for i in indexSet {
                        try? await vm.delete(id: vm.items[i].id)
                    }
                }
            }
        }
        .overlay { if vm.isLoading { ProgressView() } }
        .navigationTitle("Eğitim")
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
            Button { Task { await vm.fetch() } } label: { Image(systemName: "arrow.clockwise") }
        }
        .task { await vm.fetch() }
        .sheet(isPresented: $showAdd) {
            EducationAddView(vm: vm)
        }
    }
}
