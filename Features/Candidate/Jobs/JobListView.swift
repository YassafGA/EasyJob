import SwiftUI

struct JobListView: View {
    @StateObject private var vm = CandidateJobViewModel()

    @State private var searchText = ""
    @State private var showFilters = false

    @State private var category = ""
    @State private var seniority = ""
    @State private var workModel = ""

    var body: some View {
        List(vm.jobs) { job in
            NavigationLink {
                JobDetailView(job: job, vm: vm)
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.title ?? "Başlık yok").font(.headline)

                    Text(meta(job))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let salary = salaryLine(job) {
                        Text(salary)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .overlay {
            if vm.isLoading {
                ProgressView()
            } else if vm.jobs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("Sonuç bulunamadı")
                        .font(.headline)
                    Text("Filtreleri temizleyip tekrar deneyebilirsin.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding()
            }
        }
        .navigationTitle("İş Ara")
        .toolbar {
            Button {
                showFilters = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }

            Button {
                Task { await reload() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .searchable(text: $searchText, prompt: "Başlıkta ara (örn: iOS Developer)")
        .onSubmit(of: .search) { Task { await reload() } }
        .onChange(of: searchText) { _, newValue in
            // İstersen anlık arama: çok sorgu atar; şimdilik submit/reload ile.
            if newValue.isEmpty { Task { await reload() } }
        }
        .sheet(isPresented: $showFilters) {
            JobFilterSheet(category: $category, seniority: $seniority, workModel: $workModel)
                .onDisappear { Task { await reload() } }
        }
        .task { await reload() }
        .alert("Hata", isPresented: .constant(vm.errorMessage != nil)) {
            Button("Tamam") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private func reload() async {
        let f = CandidateJobViewModel.JobFilters(
            query: searchText,
            category: category.isEmpty ? nil : category,
            seniority: seniority.isEmpty ? nil : seniority,
            workModel: workModel.isEmpty ? nil : workModel
        )
        await vm.fetchJobs(filters: f)
    }

    private func meta(_ job: JobPost) -> String {
        var parts: [String] = []
        if let loc = job.location, !loc.isEmpty { parts.append(loc) }
        if let wm = job.work_model, !wm.isEmpty { parts.append(wm) }
        if let s = job.seniority, !s.isEmpty { parts.append(s) }
        if let c = job.job_category, !c.isEmpty { parts.append(c) }
        return parts.joined(separator: " • ")
    }

    private func salaryLine(_ job: JobPost) -> String? {
        guard job.salary_min != nil || job.salary_max != nil else { return nil }
        let cur = job.currency ?? ""
        if let mn = job.salary_min, let mx = job.salary_max {
            return "\(mn)–\(mx) \(cur)"
        } else if let mn = job.salary_min {
            return "\(mn)+ \(cur)"
        } else if let mx = job.salary_max {
            return "≤ \(mx) \(cur)"
        }
        return nil
    }
}
