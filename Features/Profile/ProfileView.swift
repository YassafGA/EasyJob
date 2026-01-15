import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        Form {
            if sessionStore.profile?.role == .company {
                Section {
                    TextField("Şirket Adı", text: $vm.companyName)
                        .textContentType(.organizationName)
                        .textInputAutocapitalization(.words)
                    TextField("Yetkili Ad Soyad", text: $vm.fullName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    TextField("Pozisyon", text: $vm.title)
                    TextField("Telefon", text: $vm.phone)
                        .keyboardType(.phonePad)
                } header: {
                    Label("Şirket Bilgileri", systemImage: "building.2")
                }

                Section {
                    TextField("Web Site", text: $vm.companyWebsite)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    TextField("Sektör", text: $vm.companySector)
                    TextField("Şirket'in Kurulum Tarihi", text: $vm.companySize)
                    TextField("Lokasyon", text: $vm.companyLocation)
                    TextField("LinkedIn URL", text: $vm.linkedinURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    TextField("Hakkında", text: $vm.companyAbout, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                } header: {
                    Label("Kurumsal Bilgiler", systemImage: "link")
                }
            } else {
                Section {
                    TextField("İsim Soyisim", text: $vm.fullName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    TextField("Meslek", text: $vm.profession)
                    TextField("Telefon", text: $vm.phone)
                        .keyboardType(.phonePad)
                    TextField("Ünvan", text: $vm.title)
                } header: {
                    Label("Temel Bilgiler", systemImage: "person")
                }

                Section {
                    TextField("GitHub URL", text: $vm.githubURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)

                    TextField("Portfolio URL", text: $vm.portfolioURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)

                    TextField("LinkedIn URL", text: $vm.linkedinURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                } header: {
                    Label("Linkler", systemImage: "link")
                }
            }

            Section {
                Button(vm.isSaving ? "Kaydediliyor..." : "Kaydet") {
                    guard let p = sessionStore.profile else { return }
                    Task { await vm.save(role: p.role, profileId: p.id, sessionStore: sessionStore) }
                }
                .disabled(vm.isSaving)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)

                if let s = vm.successMessage { Text(s).foregroundStyle(.green) }
                if let e = vm.errorMessage { Text(e).foregroundStyle(.red) }
            }

            if sessionStore.profile?.role != .company {
                Section {
                    NavigationLink { EducationListView() } label: {
                        Label("Eğitim Bilgileri", systemImage: "graduationcap")
                    }
                    NavigationLink { ExperienceListView() } label: {
                        Label("İş Deneyimi", systemImage: "briefcase")
                    }
                    NavigationLink { LanguageListView() } label: {
                        Label("Diller", systemImage: "globe")
                    }
                    NavigationLink { SkillListView() } label: {
                        Label("Yetenekler", systemImage: "hammer")
                    }
                }
            }

            Section {
                Button("Çıkış Yap", role: .destructive) {
                    Task { await sessionStore.signOut() }
                }
            }
        }
        .navigationTitle("Profil")
        .onAppear { vm.load(from: sessionStore.profile) }
    }
}
