import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @StateObject private var vm = AuthViewModel()
    @FocusState private var focusedField: Field?

    private enum Field {
        case fullName
        case email
        case password
        case companyName
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField("Ad Soyad", text: $vm.fullName)
                .textContentType(.name)
                .focused($focusedField, equals: .fullName)
                .submitLabel(.next)
                .authFieldStyle()

            TextField("Email", text: $vm.email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .authFieldStyle()

            SecureField("Şifre", text: $vm.password)
                .textContentType(.newPassword)
                .focused($focusedField, equals: .password)
                .submitLabel(vm.role == .company ? .next : .go)
                .authFieldStyle()

            Picker("Hesap Tipi", selection: $vm.role) {
                Text("Aday").tag(UserRole.candidate)
                Text("Şirket").tag(UserRole.company)
            }
            .pickerStyle(.segmented)

            if vm.role == .company {
                TextField("Şirket Adı", text: $vm.companyName)
                    .textContentType(.organizationName)
                    .focused($focusedField, equals: .companyName)
                    .submitLabel(.go)
                    .authFieldStyle()
            }

            Button {
                submit()
            } label: {
                Text(vm.isLoading ? "Kayıt oluşturuluyor..." : "Kayıt Ol")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isLoading)

            if let err = vm.errorMessage {
                Text(err)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .onSubmit {
            switch focusedField {
            case .fullName:
                focusedField = .email
            case .email:
                focusedField = .password
            case .password:
                focusedField = vm.role == .company ? .companyName : nil
                if vm.role != .company { submit() }
            case .companyName:
                submit()
            case .none:
                break
            }
        }
    }

    private func submit() {
        Task { await vm.register(sessionStore: sessionStore) }
    }
}
