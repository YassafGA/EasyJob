//
//  ExperienceListView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct ExperienceListView: View {
    @StateObject private var vm = ExperienceViewModel()
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(vm.items) { x in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(x.position) • \(x.company)")
                            .font(.headline)

                        HStack(spacing: 8) {
                            if let t = x.employment_type, !t.isEmpty {
                                Text(t).foregroundStyle(.secondary)
                            }
                            if let loc = x.location, !loc.isEmpty {
                                Text(loc).foregroundStyle(.secondary)
                            }
                            if x.is_current {
                                Text("Current").foregroundStyle(.secondary)
                            }
                        }
                        .font(.subheadline)

                        if let tech = x.tech_stack, !tech.isEmpty {
                            Text("Tech: \(tech)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        if let desc = x.description, !desc.isEmpty {
                            Text(desc)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                    }
                    Spacer()
                    Button(role: .destructive) {
                        Task { try? await vm.delete(id: x.id) }
                    } label: {
                        Text("Sil")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { try? await vm.delete(id: x.id) }
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
        .navigationTitle("Work Experience")
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
            Button { Task { await vm.fetch() } } label: { Image(systemName: "arrow.clockwise") }
        }
        .task { await vm.fetch() }
        .sheet(isPresented: $showAdd) {
            ExperienceAddView(vm: vm)
        }
    }
}
