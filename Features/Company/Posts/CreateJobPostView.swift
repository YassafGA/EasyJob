import SwiftUI

struct CreateJobPostView: View {
    @StateObject private var vm = CompanyPostsViewModel()

    @State private var title = ""
    @State private var location = ""

    @State private var jobCategory = ""
    @State private var seniority = ""
    @State private var employmentType = ""
    @State private var workModel = ""

    @State private var salaryMin = ""
    @State private var salaryMax = ""
    @State private var currency = ""

    @State private var description = ""
    @State private var responsibilities = ""
    @State private var requirements = ""
    @State private var niceToHave = ""
    @State private var benefits = ""
    @State private var techStack = ""
    @State private var deadline = "" // YYYY-MM-DD

    @State private var isSaving = false
    @State private var info: String?

    private let categories = [
        "", "Yazılım ve IT", "Tasarım ve Kreatif", "Pazarlama", "Satış", "İnsan Kaynakları",
        "Finans ve Muhasebe", "Hukuk", "Operasyon ve Lojistik", "Müşteri Hizmetleri",
        "Sağlık", "Eğitim", "İnşaat", "Üretim", "Turizm ve Otelcilik", "Perakende", "Diğer"
    ]
    private let seniorities = ["", "Stajyer", "Junior", "Mid", "Senior", "Lead"]
    private let employmentTypes = ["", "Tam Zamanlı", "Yarı Zamanlı", "Sözleşmeli", "Staj"]
    private let workModels = ["", "Uzaktan", "Hibrit", "Ofis"]
    private let currencies = ["", "TRY", "USD", "EUR"]

    var body: some View {
        Form {
            Section("Pozisyon (opsiyonel)") {
                TextField("Başlık (örn: Satış Temsilcisi)", text: $title)
                TextField("Lokasyon", text: $location)

                Picker("Kategori", selection: $jobCategory) {
                    ForEach(categories, id: \.self) { Text($0.isEmpty ? "Boş" : $0).tag($0) }
                }
                Picker("Seviye", selection: $seniority) {
                    ForEach(seniorities, id: \.self) { Text($0.isEmpty ? "Boş" : $0).tag($0) }
                }
                Picker("İstihdam", selection: $employmentType) {
                    ForEach(employmentTypes, id: \.self) { Text($0.isEmpty ? "Boş" : $0).tag($0) }
                }
                Picker("Çalışma Modeli", selection: $workModel) {
                    ForEach(workModels, id: \.self) { Text($0.isEmpty ? "Boş" : $0).tag($0) }
                }
            }

            Section("Maaş (opsiyonel)") {
                TextField("Min", text: $salaryMin).keyboardType(.numberPad)
                TextField("Max", text: $salaryMax).keyboardType(.numberPad)
                Picker("Para Birimi", selection: $currency) {
                    ForEach(currencies, id: \.self) { Text($0.isEmpty ? "Boş" : $0).tag($0) }
                }
            }

            Section("Açıklama (opsiyonel)") {
                TextEditor(text: $description).frame(height: 120)
            }

            Section("Sorumluluklar (opsiyonel)") {
                TextEditor(text: $responsibilities).frame(height: 120)
            }

            Section("Gereksinimler (opsiyonel)") {
                TextEditor(text: $requirements).frame(height: 120)
            }

            Section("Olursa iyi olur (opsiyonel)") {
                TextEditor(text: $niceToHave).frame(height: 100)
            }

            Section("Yan Haklar") {
                TextEditor(text: $benefits).frame(height: 100)
            }

            Section("Yetkinlikler (opsiyonel)") {
                TextField("örn: Excel, İletişim, Proje Yönetimi", text: $techStack)
            }

            Section("Son Başvuru Tarihi (opsiyonel)") {
                TextField("YYYY-MM-DD", text: $deadline)
            }

            Section {
                Button {
                    Task {
                        isSaving = true
                        defer { isSaving = false }

                        do {
                            let sMin = Int(salaryMin)
                            let sMax = Int(salaryMax)

                            try await vm.createPost(
                                title: title.trimmedOrNil(),
                                location: location.trimmedOrNil(),
                                jobCategory: jobCategory.trimmedOrNil(),
                                seniority: seniority.trimmedOrNil(),
                                employmentType: employmentType.trimmedOrNil(),
                                workModel: workModel.trimmedOrNil(),
                                salaryMin: sMin,
                                salaryMax: sMax,
                                currency: currency.trimmedOrNil(),
                                description: description.trimmedOrNil(),
                                responsibilities: responsibilities.trimmedOrNil(),
                                requirements: requirements.trimmedOrNil(),
                                niceToHave: niceToHave.trimmedOrNil(),
                                benefits: benefits.trimmedOrNil(),
                                techStack: techStack.trimmedOrNil(),
                                applicationDeadline: deadline.trimmedOrNil()
                            )

                            info = "İlan oluşturuldu ✅"
                            title = ""
                            description = ""
                            responsibilities = ""
                            requirements = ""
                            niceToHave = ""
                            benefits = ""
                            salaryMin = ""
                            salaryMax = ""
                            deadline = ""
                        } catch {
                            info = "Hata: \(error.localizedDescription)"
                        }
                    }
                } label: {
                    Text(isSaving ? "Kaydediliyor..." : "İlanı Yayınla")
                        .frame(maxWidth: .infinity)
                }
                .disabled(isSaving)

                if let info {
                    Text(info).foregroundStyle(info.contains("✅") ? .green : .red)
                }
            }
        }
        .navigationTitle("Yeni İlan")
    }
}

private extension String {
    func trimmedOrNil() -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
