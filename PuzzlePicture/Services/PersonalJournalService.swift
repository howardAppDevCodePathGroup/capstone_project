import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

final class PersonalJournalService {
    private let db = FirebaseManager.shared.db
    private let storage = FirebaseManager.shared.storage

    func saveEntry(
        userId: String,
        text: String,
        image: UIImage?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let entryId = UUID().uuidString

        if let image {
            uploadJournalImage(image, userId: userId, entryId: entryId) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    self?.saveEntryDocument(
                        entryId: entryId,
                        userId: userId,
                        text: text,
                        imageURL: imageURL,
                        completion: completion
                    )
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            saveEntryDocument(
                entryId: entryId,
                userId: userId,
                text: text,
                imageURL: "",
                completion: completion
            )
        }
    }

    func listenToEntries(userId: String, completion: @escaping (Result<[PersonalJournalEntry], Error>) -> Void) -> ListenerRegistration {
        return db.collection("personalJournals")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let entries: [PersonalJournalEntry] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let timestamp = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())

                    return PersonalJournalEntry(
                        id: doc.documentID,
                        userId: data["userId"] as? String ?? "",
                        text: data["text"] as? String ?? "",
                        imageURL: data["imageURL"] as? String ?? "",
                        createdAt: timestamp.dateValue()
                    )
                } ?? []

                completion(.success(entries))
            }
    }

    private func saveEntryDocument(
        entryId: String,
        userId: String,
        text: String,
        imageURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let data: [String: Any] = [
            "entryId": entryId,
            "userId": userId,
            "text": text,
            "imageURL": imageURL,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("personalJournals").document(entryId).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    private func uploadJournalImage(
        _ image: UIImage,
        userId: String,
        entryId: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.82) else {
            completion(.failure(NSError(domain: "PersonalJournalService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not convert image."])))
            return
        }

        let ref = storage.reference().child("personalJournals/\(userId)/\(entryId).jpg")
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
                    completion(.failure(NSError(domain: "PersonalJournalService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not get image URL."])))
                }
            }
        }
    }
}
