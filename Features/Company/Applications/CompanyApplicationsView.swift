import SwiftUI

struct CompanyApplicationsView: View {
    @StateObject private var vm = CompanyApplicationsViewModel()
    @State private var expandedIds: Set<UUID> = []

    var body: some View {
        List {
            Section {
                NavigationLink {
                    CompanyApplicationsArchiveView(vm: vm)
                } label: {
                    Label("Arşiv", systemImage: "archivebox")
                }
            }
            ForEach(vm.groups) { group in
                Section {
                    let pendingApps = group.applications.filter { $0.status != "accepted" && $0.status != "rejected" }
                    if pendingApps.isEmpty {
                        Text("Bu ilana henüz başvuru yok.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(pendingApps) { app in
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedIds.contains(app.id) },
                                    set: { isOpen in
                                        if isOpen { expandedIds.insert(app.id) } else { expandedIds.remove(app.id) }
                                    }
                                )
                            ) {
                                applicantDetails(app)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(app.candidate?.full_name ?? "İsim yok")
                                        .font(.headline)
                                    Text("Durum: \(app.status.capitalized)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.title ?? "Başlık yok")
                            .font(.headline)
                        if let loc = group.location, !loc.isEmpty {
                            Text(loc).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .overlay { if vm.isLoading { ProgressView() } }
        .navigationTitle("Başvurular")
        .toolbar {
            Button { Task { await vm.fetchAll() } } label: { Image(systemName: "arrow.clockwise") }
        }
        .task { await vm.fetchAll() }
        .alert("Hata", isPresented: .constant(vm.errorMessage != nil)) {
            Button("Tamam") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func applicantDetails(_ app: CompanyApplicationsViewModel.CompanyApplicationRow) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let email = app.candidate?.email, !email.isEmpty {
                Text("Email: \(email)")
            }
            if let phone = app.candidate?.phone, !phone.isEmpty {
                Text("Telefon: \(phone)")
            }
            if let title = app.candidate?.title, !title.isEmpty {
                Text("Ünvan: \(title)")
            }
            if let linkedin = app.candidate?.linkedin_url, !linkedin.isEmpty {
                Text("LinkedIn: \(linkedin)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let portfolio = app.candidate?.portfolio_url, !portfolio.isEmpty {
                Text("Portfolio: \(portfolio)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let cl = app.cover_letter, !cl.isEmpty {
                Divider()
                Text("Ön Yazı")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(cl)
                    .font(.footnote)
            }

            HStack(spacing: 12) {
                Button {
                    Task {
                        try? await vm.updateStatus(applicationId: app.id, newStatus: "accepted")
                        await vm.fetchAll()
                    }
                } label: {
                    Label("Onayla", systemImage: "checkmark.circle")
                }
                .buttonStyle(.borderedProminent)

                Button(role: .destructive) {
                    Task {
                        try? await vm.updateStatus(applicationId: app.id, newStatus: "rejected")
                        await vm.fetchAll()
                    }
                } label: {
                    Label("Reddet", systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
            }

            if let cv = app.cv_url, let url = URL(string: cv) {
                Link(destination: url) {
                    Label("CV İndir", systemImage: "arrow.down.doc")
                }
                .buttonStyle(.bordered)
            } else {
                Text("CV eklenmemiş")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
