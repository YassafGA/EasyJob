import SwiftUI

struct MyApplicationsView: View {
    @StateObject private var vm = MyApplicationsViewModel()

    @State private var showWithdrawConfirm = false
    @State private var pendingWithdrawApp: MyApplicationRow?

    var body: some View {
        List {
            ForEach(vm.apps) { app in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(app.job_title)
                            .font(.headline)

                        Text(meta(app))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Durum: \(app.status)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        pendingWithdrawApp = app
                        showWithdrawConfirm = true
                    } label: {
                        Label("Başvuruyu Geri Al", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        pendingWithdrawApp = app
                        showWithdrawConfirm = true
                    } label: {
                        Label("Geri Al", systemImage: "xmark.circle")
                    }
                }
            }

            if vm.apps.isEmpty && !vm.isLoading {
                Text("Henüz başvurun yok.")
                    .foregroundStyle(.secondary)
            }
        }
        .overlay { if vm.isLoading { ProgressView() } }
        .navigationTitle("Başvurularım")
        .toolbar {
            Button {
                Task { await vm.fetchMyApplications() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .task { await vm.fetchMyApplications() }
        .alert("Başvuruyu geri almak istiyor musun?", isPresented: $showWithdrawConfirm) {
            Button("Vazgeç", role: .cancel) {
                pendingWithdrawApp = nil
            }
            Button("Geri Al", role: .destructive) {
                guard let app = pendingWithdrawApp else { return }
                Task {
                    do {
                        try await vm.withdraw(applicationId: app.id)
                        await vm.fetchMyApplications()
                        pendingWithdrawApp = nil
                    } catch {
                        vm.errorMessage = error.localizedDescription
                    }
                }
            }
        } message: {
            Text("Bu işlem başvurunu sistemden kaldırır.")
        }
        .alert("Hata", isPresented: .constant(vm.errorMessage != nil)) {
            Button("Tamam") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private func meta(_ app: MyApplicationRow) -> String {
        var parts: [String] = []
        parts.append(app.job_location)
        if let wm = app.job_work_model, !wm.isEmpty { parts.append(wm) }
        if let s = app.job_seniority, !s.isEmpty { parts.append(s) }
        return parts.joined(separator: " • ")
    }
}
