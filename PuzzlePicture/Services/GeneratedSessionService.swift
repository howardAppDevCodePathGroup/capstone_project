import Foundation
import FirebaseFirestore

final class GeneratedSessionService {
    private let db = FirebaseManager.shared.db

    func fetchSession(sessionId: String, completion: @escaping (Result<GeneratedSession, Error>) -> Void) {
        db.collection("sessions").document(sessionId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                completion(.failure(
                    NSError(
                        domain: "GeneratedSessionService",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Session not found."]
                    )
                ))
                return
            }

            let session = GeneratedSession(
                id: snapshot?.documentID ?? sessionId,
                sessionId: data["sessionId"] as? String ?? sessionId,
                groupId: data["groupId"] as? String ?? "",
                groupName: data["groupName"] as? String ?? "Group Session",
                promptTheme: data["promptTheme"] as? String ?? "",
                generatedImageURL: data["generatedImageURL"] as? String ?? "",
                pieceCount: data["pieceCount"] as? Int ?? 0,
                status: data["status"] as? String ?? "unknown"
            )

            completion(.success(session))
        }
    }

    func fetchGroupName(groupId: String, completion: @escaping (String) -> Void) {
        db.collection("groups").document(groupId).getDocument { snapshot, _ in
            let name = snapshot?.data()?["name"] as? String ?? "Group Session"
            completion(name)
        }
    }

    func listenToSession(sessionId: String, completion: @escaping (Result<GeneratedSession, Error>) -> Void) -> ListenerRegistration {
        db.collection("sessions").document(sessionId).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                completion(.failure(
                    NSError(
                        domain: "GeneratedSessionService",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Session not found."]
                    )
                ))
                return
            }

            let session = GeneratedSession(
                id: snapshot?.documentID ?? sessionId,
                sessionId: data["sessionId"] as? String ?? sessionId,
                groupId: data["groupId"] as? String ?? "",
                groupName: data["groupName"] as? String ?? "Group Session",
                promptTheme: data["promptTheme"] as? String ?? "",
                generatedImageURL: data["generatedImageURL"] as? String ?? "",
                pieceCount: data["pieceCount"] as? Int ?? 0,
                status: data["status"] as? String ?? "unknown"
            )

            completion(.success(session))
        }
    }
}
