import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUserEmail: String = ""
    @Published var errorMessage: String = ""

    func login(email: String, password: String) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard password.count >= 4 else {
            errorMessage = "Password must be at least 4 characters."
            return
        }

        errorMessage = ""
        currentUserEmail = email
        isLoggedIn = true
    }

    func signUp(email: String, password: String) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard password.count >= 4 else {
            errorMessage = "Password must be at least 4 characters."
            return
        }

        errorMessage = ""
        currentUserEmail = email
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
        currentUserEmail = ""
        errorMessage = ""
    }
}
