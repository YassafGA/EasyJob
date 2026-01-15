import SwiftUI

struct SkillListView: View {
    @StateObject private var vm = SkillViewModel()
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(vm.items) { s in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.skill).font(.headline)
                        if let level = s.level, !level.isEmpty {
                            Text(level).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Button(role: .destructive) {
                        Task { try? await vm.delete(id: s.id) }
                    } label: {
                        Text("Sil")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { try? await vm.delete(id: s.id) }
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
        .navigationTitle("Yetenekler")
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
            Button { Task { await vm.fetch() } } label: { Image(systemName: "arrow.clockwise") }
        }
        .task { await vm.fetch() }
        .sheet(isPresented: $showAdd) {
            SkillAddView(vm: vm)
        }
    }
}
