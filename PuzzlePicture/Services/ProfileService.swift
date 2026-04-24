import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

final class ProfileService {
    private let db = FirebaseManager.shared.db
    private let storage = FirebaseManager.shared.storage

    func fetchProfile(uid: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                completion(.failure(NSError(domain: "ProfileService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found."])))
                return
            }

            let user = AppUser(
                id: uid,
                email: data["email"] as? String ?? "",
                firstName: data["firstName"] as? String ?? "",
                lastName: data["lastName"] as? String ?? "",
                displayName: data["displayName"] as? String ?? "",
                profileImageURL: data["profileImageURL"] as? String ?? "",
                coverImageURL: data["coverImageURL"] as? String ?? "",
                bio: data["bio"] as? String ?? ""
            )

            completion(.success(user))
        }
    }

    func updateProfile(
        uid: String,
        firstName: String,
        lastName: String,
        bio: String,
        profileImageURL: String,
        coverImageURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let displayName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)

        let data: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "displayName": displayName,
            "bio": bio,
            "profileImageURL": profileImageURL,
            "coverImageURL": coverImageURL
        ]

        db.collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func uploadImage(_ image: UIImage, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ProfileService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data."])))
            return
        }

        let ref = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        ref.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "ProfileService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not fetch download URL."])))
                }
            }
        }
    }
}
