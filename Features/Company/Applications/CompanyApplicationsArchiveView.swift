import SwiftUI

struct CompanyApplicationsArchiveView: View {
    @ObservedObject var vm: CompanyApplicationsViewModel
    @State private var expandedIds: Set<UUID> = []
    @State private var showClearConfirm = false

    var body: some View {
        let model = vm
        return List {
            ForEach(model.groups) { group in
                CompanyApplicationsArchiveGroupSection(group: group, expandedIds: $expandedIds, vm: model)
            }
        }
        .navigationTitle("Arşiv")
        .toolbar {
            Button { Task { await model.fetchAll() } } label: { Image(systemName: "arrow.clockwise") }
            Button(role: .destructive) { showClearConfirm = true } label: {
                Text("Arşivi Temizle")
            }
        }
        .alert("Arşiv temizlensin mi?", isPresented: $showClearConfirm) {
            Button("Vazgeç", role: .cancel) {}
            Button("Temizle", role: .destructive) {
                Task {
                    do {
                        try await model.clearArchived()
                        await model.fetchAll()
                    } catch {
                        model.errorMessage = error.localizedDescription
                    }
                }
            }
        } message: {
            Text("Kabul edilen ve reddedilen başvurular silinir.")
        }
    }
}

private struct CompanyApplicationsArchiveGroupSection: View {
    let group: CompanyApplicationsViewModel.CompanyJobGroup
    @Binding var expandedIds: Set<UUID>
    @ObservedObject var vm: CompanyApplicationsViewModel

    private var acceptedApps: [CompanyApplicationsViewModel.CompanyApplicationRow] {
        group.applications.filter { $0.status == "accepted" }
    }

    private var rejectedApps: [CompanyApplicationsViewModel.CompanyApplicationRow] {
        group.applications.filter { $0.status == "rejected" }
    }

    var body: some View {
        Section {
            if acceptedApps.isEmpty && rejectedApps.isEmpty {
                Text("Bu ilanda arşivlenmiş başvuru yok.")
                    .foregroundStyle(.secondary)
            }

            if !acceptedApps.isEmpty {
                Text("Kabul Edilenler")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                ForEach(acceptedApps) { app in
                    disclosure(app: app, statusText: "Durum: Kabul Edildi")
                }
            }

            if !rejectedApps.isEmpty {
                Text("Reddedilenler")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                ForEach(rejectedApps) { app in
                    disclosure(app: app, statusText: "Durum: Reddedildi")
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

    private func disclosure(app: CompanyApplicationsViewModel.CompanyApplicationRow, statusText: String) -> some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expandedIds.contains(app.id) },
                set: { isOpen in
                    if isOpen { expandedIds.insert(app.id) } else { expandedIds.remove(app.id) }
                }
            )
        ) {
            CompanyApplicationsArchiveDetails(app: app, showDelete: true, vm: vm)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(app.candidate?.full_name ?? "İsim yok")
                    .font(.headline)
                Text(statusText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct CompanyApplicationsArchiveDetails: View {
    let app: CompanyApplicationsViewModel.CompanyApplicationRow
    var showDelete: Bool = false
    @ObservedObject var vm: CompanyApplicationsViewModel

    var body: some View {
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

            if showDelete {
                Button(role: .destructive) {
                    Task {
                        try? await vm.deleteApplication(applicationId: app.id)
                        await vm.fetchAll()
                    }
                } label: {
                    Text("Sil")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 6)
    }
}
