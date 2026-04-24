import Foundation
import FirebaseFirestore

final class JournalService {
    private let db = FirebaseManager.shared.db

    func submitJournal(sessionId: String, groupId: String, userId: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let submissionId = "\(sessionId)_\(userId)"
        let ref = db.collection("submissions").document(submissionId)

        ref.getDocument { [weak self] snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if snapshot?.exists == true {
                completion(.failure(
                    NSError(
                        domain: "JournalService",
                        code: 409,
                        userInfo: [NSLocalizedDescriptionKey: "You have already submitted your puzzle journal for this group session."]
                    )
                ))
                return
            }

            let data: [String: Any] = [
                "submissionId": submissionId,
                "sessionId": sessionId,
                "groupId": groupId,
                "userId": userId,
                "journalText": text,
                "submittedAt": Timestamp(date: Date())
            ]

            self?.db.collection("submissions").document(submissionId).setData(data) { setError in
                if let setError = setError {
                    completion(.failure(setError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    func checkIfUserSubmitted(sessionId: String, userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let submissionId = "\(sessionId)_\(userId)"

        db.collection("submissions").document(submissionId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(snapshot?.exists == true))
            }
        }
    }

    func listenForSubmissionCount(groupId: String, sessionId: String, completion: @escaping (Int) -> Void) -> ListenerRegistration {
        db.collection("submissions")
            .whereField("groupId", isEqualTo: groupId)
            .whereField("sessionId", isEqualTo: sessionId)
            .addSnapshotListener { snapshot, _ in
                completion(snapshot?.documents.count ?? 0)
            }
    }

    func listenForSubmittedUsers(groupId: String, sessionId: String, completion: @escaping ([String]) -> Void) -> ListenerRegistration {
        db.collection("submissions")
            .whereField("groupId", isEqualTo: groupId)
            .whereField("sessionId", isEqualTo: sessionId)
            .addSnapshotListener { snapshot, _ in
                let users = snapshot?.documents.compactMap { doc in
                    doc.data()["userId"] as? String
                } ?? []
                completion(users.sorted())
            }
    }
}
