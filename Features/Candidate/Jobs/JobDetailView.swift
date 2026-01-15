import SwiftUI
import UniformTypeIdentifiers

struct JobDetailView: View {
    let job: JobPost
    @ObservedObject var vm: CandidateJobViewModel

    @State private var coverLetter = ""
    @State private var isApplying = false
    @State private var info: String?
    @State private var showCVPicker = false
    @State private var cvFileURL: URL?
    @State private var cvError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(job.title ?? "Başlık yok").font(.title2).bold()
                Text(metaLine).foregroundStyle(.secondary)

                if let salary = salaryLine {
                    Text(salary).foregroundStyle(.secondary)
                }

                Divider().padding(.vertical, 6)

                if let desc = job.description, !desc.isEmpty {
                    section("Açıklama", desc)
                } else {
                    section("Açıklama", "Belirtilmemiş")
                }

                if let r = job.responsibilities, !r.isEmpty {
                    section("Sorumluluklar", r)
                }

                if let req = job.requirements, !req.isEmpty {
                    section("Gereksinimler", req)
                } else {
                    section("Gereksinimler", "Belirtilmemiş")
                }

                if let n = job.nice_to_have, !n.isEmpty {
                    section("Olursa iyi olur", n)
                }

                if let b = job.benefits, !b.isEmpty {
                    section("Yan Haklar", b)
                }

                if let ts = job.tech_stack, !ts.isEmpty {
                    section("Tech Stack", ts)
                }

                Divider().padding(.vertical, 8)

                Text("Ön Yazı (opsiyonel)").font(.headline)
                TextEditor(text: $coverLetter)
                    .frame(height: 120)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))

                VStack(alignment: .leading, spacing: 6) {
                    Text("CV (PDF/DOCX)").font(.headline)
                    if let url = cvFileURL {
                        Text(url.lastPathComponent)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    if let err = cvError {
                        Text(err).foregroundStyle(.red).font(.footnote)
                    }
                    Button {
                        showCVPicker = true
                    } label: {
                        Text("CV Seç")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    Task {
                        isApplying = true
                        defer { isApplying = false }
                        do {
                            cvError = nil
                            try await vm.apply(jobId: job.id, coverLetter: coverLetter.isEmpty ? nil : coverLetter, cvFileURL: cvFileURL)
                            info = "Başvuru gönderildi ✅"
                        } catch {
                            info = "Başvuru başarısız: \(error.localizedDescription)"
                        }
                    }
                } label: {
                    Text(isApplying ? "Gönderiliyor..." : "Başvur")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isApplying)

                if let info {
                    Text(info)
                        .foregroundStyle(info.contains("✅") ? .green : .red)
                }
            }
            .padding()
        }
        .navigationTitle("Detay")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $showCVPicker,
            allowedContentTypes: [UTType.pdf, UTType(filenameExtension: "docx")].compactMap { $0 },
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                cvFileURL = urls.first
                cvError = nil
            case .failure(let error):
                cvError = error.localizedDescription
            }
        }
    }

    private var metaLine: String {
        var parts: [String] = []
        if let loc = job.location, !loc.isEmpty { parts.append(loc) }
        if let wm = job.work_model, !wm.isEmpty { parts.append(wm) }
        if let et = job.employment_type, !et.isEmpty { parts.append(et) }
        if let s = job.seniority, !s.isEmpty { parts.append(s) }
        if let c = job.job_category, !c.isEmpty { parts.append(c) }
        return parts.joined(separator: " • ")
    }

    private var salaryLine: String? {
        guard job.salary_min != nil || job.salary_max != nil else { return nil }
        let cur = job.currency ?? ""
        if let mn = job.salary_min, let mx = job.salary_max {
            return "Maaş: \(mn)–\(mx) \(cur)"
        } else if let mn = job.salary_min {
            return "Maaş: \(mn)+ \(cur)"
        } else if let mx = job.salary_max {
            return "Maaş: ≤ \(mx) \(cur)"
        }
        return nil
    }

    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(body)
        }
    }
}
