import SwiftUI

struct ApplicantsForPostView: View {
    let jobPost: JobPost
    @StateObject private var vm = ApplicantsViewModel()

    private let statuses = ["submitted", "seen", "accepted", "rejected"]

    var body: some View {
        List {
            ForEach(vm.applications) { app in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Aday ID: \(app.candidate_id.uuidString.prefix(8))...")
                        .font(.headline)

                    Picker("Durum", selection: Binding(
                        get: { app.status },
                        set: { newValue in
                            Task {
                                await vm.updateStatus(
                                    applicationId: app.id,
                                    newStatus: newValue,
                                    jobId: jobPost.id
                                )
                            }
                        }
                    )) {
                        ForEach(statuses, id: \.self) { s in
                            Text(s.capitalized).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)

                    if let cl = app.cover_letter, !cl.isEmpty {
                        Text("Ön Yazı:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(cl)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .overlay { if vm.isLoading { ProgressView() } }
        .navigationTitle("Başvurular")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                Task { await vm.fetchApplicants(for: jobPost.id) }
            } label: { Image(systemName: "arrow.clockwise") }
        }
        .task { await vm.fetchApplicants(for: jobPost.id) }
        .alert("Hata", isPresented: .constant(vm.errorMessage != nil)) {
            Button("Tamam") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
