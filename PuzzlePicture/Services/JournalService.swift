import Foundation
import FirebaseFirestore

final class JournalService {
    private let db = FirebaseManager.shared.db

    func submitJournal(sessionId: String, groupId: String, userId: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = db.collection("submissions").document()

        let data: [String: Any] = [
            "submissionId": ref.documentID,
            "sessionId": sessionId,
            "groupId": groupId,
            "userId": userId,
            "journalText": text,
            "submittedAt": Timestamp(date: Date())
        ]

        ref.setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
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
}
