import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @StateObject private var vm = AuthViewModel()
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField("Email", text: $vm.email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .authFieldStyle()

            SecureField("Şifre", text: $vm.password)
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .authFieldStyle()

            Button {
                submit()
            } label: {
                Text(vm.isLoading ? "Giriş yapılıyor..." : "Giriş Yap")
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
            case .email:
                focusedField = .password
            case .password:
                submit()
            case .none:
                break
            }
        }
    }

    private func submit() {
        Task { await vm.login(sessionStore: sessionStore) }
    }
}
