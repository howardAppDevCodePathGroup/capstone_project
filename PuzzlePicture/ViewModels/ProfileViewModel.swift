import Foundation
import Combine
import UIKit

final class ProfileViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var bio: String = ""

    @Published var profileImageURL: String = ""
    @Published var coverImageURL: String = ""

    @Published var profileUIImage: UIImage?
    @Published var coverUIImage: UIImage?

    @Published var isLoading = false
    @Published var statusMessage = ""
    @Published var errorMessage = ""

    private let service = ProfileService()

    func loadProfile(uid: String) {
        isLoading = true
        errorMessage = ""

        service.fetchProfile(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let user):
                    self?.firstName = user.firstName
                    self?.lastName = user.lastName
                    self?.email = user.email
                    self?.bio = user.bio
                    self?.profileImageURL = user.profileImageURL
                    self?.coverImageURL = user.coverImageURL
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func saveProfile(uid: String) {
        isLoading = true
        statusMessage = ""
        errorMessage = ""

        let cleanFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanFirstName.isEmpty else {
            isLoading = false
            errorMessage = "First name cannot be empty."
            return
        }

        guard !cleanLastName.isEmpty else {
            isLoading = false
            errorMessage = "Last name cannot be empty."
            return
        }

        uploadImagesIfNeeded(uid: uid) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let urls):
                    self.service.updateProfile(
                        uid: uid,
                        firstName: cleanFirstName,
                        lastName: cleanLastName,
                        bio: cleanBio,
                        profileImageURL: urls.profileURL,
                        coverImageURL: urls.coverURL
                    ) { updateResult in
                        DispatchQueue.main.async {
                            self.isLoading = false

                            switch updateResult {
                            case .success:
                                self.profileImageURL = urls.profileURL
                                self.coverImageURL = urls.coverURL
                                self.statusMessage = "Profile updated successfully."
                            case .failure(let error):
                                self.errorMessage = error.localizedDescription
                            }
                        }
                    }

                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func uploadImagesIfNeeded(
        uid: String,
        completion: @escaping (Result<(profileURL: String, coverURL: String), Error>) -> Void
    ) {
        let existingProfileURL = profileImageURL
        let existingCoverURL = coverImageURL

        if let profileUIImage, let coverUIImage {
            uploadProfileThenCover(
                uid: uid,
                profileImage: profileUIImage,
                coverImage: coverUIImage,
                completion: completion
            )
            return
        }

        if let profileUIImage {
            service.uploadImage(profileUIImage, path: "users/\(uid)/profile.jpg") { [weak self] result in
                switch result {
                case .success(let profileURL):
                    completion(.success((profileURL: profileURL, coverURL: self?.coverImageURL ?? existingCoverURL)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }

        if let coverUIImage {
            service.uploadImage(coverUIImage, path: "users/\(uid)/cover.jpg") { [weak self] result in
                switch result {
                case .success(let coverURL):
                    completion(.success((profileURL: self?.profileImageURL ?? existingProfileURL, coverURL: coverURL)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }

        completion(.success((profileURL: existingProfileURL, coverURL: existingCoverURL)))
    }

    private func uploadProfileThenCover(
        uid: String,
        profileImage: UIImage,
        coverImage: UIImage,
        completion: @escaping (Result<(profileURL: String, coverURL: String), Error>) -> Void
    ) {
        service.uploadImage(profileImage, path: "users/\(uid)/profile.jpg") { [weak self] profileResult in
            switch profileResult {
            case .success(let profileURL):
                self?.service.uploadImage(coverImage, path: "users/\(uid)/cover.jpg") { coverResult in
                    switch coverResult {
                    case .success(let coverURL):
                        completion(.success((profileURL: profileURL, coverURL: coverURL)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
