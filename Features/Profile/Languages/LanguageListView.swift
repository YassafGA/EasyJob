//
//  LanguageListView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct LanguageListView: View {
    @StateObject private var vm = LanguageViewModel()
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(vm.items) { l in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(l.language).font(.headline)
                        Text(l.level).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        Task { try? await vm.delete(id: l.id) }
                    } label: {
                        Text("Sil")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { try? await vm.delete(id: l.id) }
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
        .navigationTitle("Diller")
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
            Button { Task { await vm.fetch() } } label: { Image(systemName: "arrow.clockwise") }
        }
        .task { await vm.fetch() }
        .sheet(isPresented: $showAdd) {
            LanguageAddView(vm: vm)
        }
    }
}
