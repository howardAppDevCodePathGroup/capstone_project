import Foundation
import FirebaseFirestore

final class GroupService {
    private let db = FirebaseManager.shared.db

    func createGroup(name: String, ownerId: String, completion: @escaping (Result<(groupId: String, inviteCode: String), Error>) -> Void) {
        let groupRef = db.collection("groups").document()
        let sessionRef = db.collection("sessions").document()
        let inviteCode = String(UUID().uuidString.prefix(6)).uppercased()

        let groupData: [String: Any] = [
            "groupId": groupRef.documentID,
            "name": name,
            "inviteCode": inviteCode,
            "ownerId": ownerId,
            "memberIds": [ownerId],
            "currentSessionId": sessionRef.documentID,
            "createdAt": Timestamp(date: Date())
        ]

        let sessionData: [String: Any] = [
            "sessionId": sessionRef.documentID,
            "groupId": groupRef.documentID,
            "status": "collecting",
            "promptTheme": "How did today feel?",
            "generatedImageURL": "",
            "pieceCount": 0,
            "createdAt": Timestamp(date: Date())
        ]

        let batch = db.batch()
        batch.setData(groupData, forDocument: groupRef)
        batch.setData(sessionData, forDocument: sessionRef)

        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success((groupRef.documentID, inviteCode)))
            }
        }
    }

    func joinGroup(inviteCode: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("groups")
            .whereField("inviteCode", isEqualTo: inviteCode.uppercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "GroupService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not found"])))
                    return
                }

                let currentSessionId = doc.data()["currentSessionId"] as? String ?? ""

                doc.reference.updateData([
                    "memberIds": FieldValue.arrayUnion([userId])
                ]) { updateError in
                    if let updateError = updateError {
                        completion(.failure(updateError))
                    } else {
                        completion(.success(currentSessionId))
                    }
                }
            }
    }
}
