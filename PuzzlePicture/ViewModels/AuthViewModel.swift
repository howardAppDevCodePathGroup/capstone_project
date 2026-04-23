import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isEmailVerified: Bool = false
    @Published var currentUserEmail: String = ""
    @Published var currentUserId: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var displayName: String = ""
    @Published var bio: String = ""
    @Published var profileImageURL: String = ""
    @Published var coverImageURL: String = ""
    @Published var errorMessage: String = ""
    @Published var infoMessage: String = ""

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    private func listenToAuthState() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }

            DispatchQueue.main.async {
                if let user = user {
                    self.isLoggedIn = true
                    self.currentUserEmail = user.email ?? ""
                    self.currentUserId = user.uid
                    self.isEmailVerified = user.isEmailVerified
                    self.errorMessage = ""

                    self.fetchUserProfile(uid: user.uid)
                } else {
                    self.resetLocalState()
                }
            }
        }
    }

    func signUp(firstName: String, lastName: String, email: String, password: String) {
        let cleanFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanFirstName.isEmpty else {
            errorMessage = "Please enter your first name."
            return
        }

        guard !cleanLastName.isEmpty else {
            errorMessage = "Please enter your last name."
            return
        }

        guard !cleanEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        errorMessage = ""
        infoMessage = ""

        Auth.auth().createUser(withEmail: cleanEmail, password: password) { [weak self] result, error in
            guard let self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let user = result?.user else {
                    self.errorMessage = "Could not create account."
                    return
                }

                let fullName = "\(cleanFirstName) \(cleanLastName)"
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = fullName

                changeRequest.commitChanges { profileError in
                    if let profileError = profileError {
                        self.errorMessage = profileError.localizedDescription
                        return
                    }

                    self.createUserDocument(
                        uid: user.uid,
                        email: cleanEmail,
                        firstName: cleanFirstName,
                        lastName: cleanLastName
                    )

                    user.sendEmailVerification { verificationError in
                        DispatchQueue.main.async {
                            if let verificationError = verificationError {
                                self.errorMessage = verificationError.localizedDescription
                            } else {
                                self.infoMessage = "Verification email sent. Please check your inbox and verify your email."
                            }
                        }
                    }
                }
            }
        }
    }

    func login(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }

        errorMessage = ""
        infoMessage = ""

        Auth.auth().signIn(withEmail: cleanEmail, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = ""
                }
            }
        }
    }

    func resendVerificationEmail() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No signed-in user found."
            return
        }

        user.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.infoMessage = "Verification email sent again."
                }
            }
        }
    }

    func refreshVerificationStatus() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No signed-in user found."
            return
        }

        user.reload { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                let refreshedUser = Auth.auth().currentUser
                self?.isEmailVerified = refreshedUser?.isEmailVerified ?? false

                if self?.isEmailVerified == true {
                    self?.infoMessage = "Email verified successfully."
                } else {
                    self?.infoMessage = "Your email is still not verified yet."
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            resetLocalState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetLocalState() {
        isLoggedIn = false
        isEmailVerified = false
        currentUserEmail = ""
        currentUserId = ""
        firstName = ""
        lastName = ""
        displayName = ""
        bio = ""
        profileImageURL = ""
        coverImageURL = ""
        errorMessage = ""
        infoMessage = ""
    }

    private func createUserDocument(uid: String, email: String, firstName: String, lastName: String) {
        let db = Firestore.firestore()

        let data: [String: Any] = [
            "uid": uid,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "displayName": "\(firstName) \(lastName)",
            "profileImageURL": "",
            "coverImageURL": "",
            "bio": "",
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("users").document(uid).setData(data, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func fetchUserProfile(uid: String) {
        let db = Firestore.firestore()

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let data = snapshot?.data() else { return }

                self?.firstName = data["firstName"] as? String ?? ""
                self?.lastName = data["lastName"] as? String ?? ""
                self?.displayName = data["displayName"] as? String ?? ""
                self?.bio = data["bio"] as? String ?? ""
                self?.profileImageURL = data["profileImageURL"] as? String ?? ""
                self?.coverImageURL = data["coverImageURL"] as? String ?? ""
            }
        }
    }
}
