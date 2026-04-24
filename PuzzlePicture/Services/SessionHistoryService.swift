import Foundation
import FirebaseFirestore

final class SessionHistoryService {
    private let db = FirebaseManager.shared.db

    func listenToHistory(userId: String, completion: @escaping (Result<[SessionHistoryEntry], Error>) -> Void) -> ListenerRegistration {
        return db.collection("users")
            .document(userId)
            .collection("sessionHistory")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let items: [SessionHistoryEntry] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let timestamp = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())

                    return SessionHistoryEntry(
                        id: doc.documentID,
                        sessionId: data["sessionId"] as? String ?? "",
                        groupId: data["groupId"] as? String ?? "",
                        groupName: data["groupName"] as? String ?? "Group",
                        finalImageURL: data["finalImageURL"] as? String ?? "",
                        pieceURL: data["pieceURL"] as? String ?? "",
                        promptTheme: data["promptTheme"] as? String ?? "",
                        createdAt: timestamp.dateValue()
                    )
                } ?? []

                completion(.success(items))
            }
    }
}
