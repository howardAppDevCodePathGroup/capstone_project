import Foundation
import FirebaseFirestore

final class AIService {
    private let db = FirebaseManager.shared.db

    func generatePuzzleForSession(
        sessionId: String,
        groupId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let sessionRef = db.collection("sessions").document(sessionId)
        let groupRef = db.collection("groups").document(groupId)

        sessionRef.updateData([
            "status": "generating"
        ]) { [weak self] error in
            if let error = error {
                completion(.failure(error))
                return
            }

            self?.buildSessionAssets(sessionId: sessionId, groupId: groupId, groupRef: groupRef, sessionRef: sessionRef, completion: completion)
        }
    }

    private func buildSessionAssets(
        sessionId: String,
        groupId: String,
        groupRef: DocumentReference,
        sessionRef: DocumentReference,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        groupRef.getDocument { [weak self] groupSnapshot, groupError in
            if let groupError = groupError {
                completion(.failure(groupError))
                return
            }

            guard let groupData = groupSnapshot?.data() else {
                completion(.failure(NSError(domain: "AIService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not found."])))
                return
            }

            let memberIds = groupData["memberIds"] as? [String] ?? []

            self?.db.collection("submissions")
                .whereField("groupId", isEqualTo: groupId)
                .whereField("sessionId", isEqualTo: sessionId)
                .getDocuments { submissionsSnapshot, submissionsError in
                    if let submissionsError = submissionsError {
                        completion(.failure(submissionsError))
                        return
                    }

                    let submissions = submissionsSnapshot?.documents ?? []

                    guard submissions.count == memberIds.count, !memberIds.isEmpty else {
                        completion(.failure(
                            NSError(
                                domain: "AIService",
                                code: 409,
                                userInfo: [NSLocalizedDescriptionKey: "Cannot generate image until all members have submitted."]
                            )
                        ))
                        return
                    }

                    let combinedPrompt = submissions
                        .compactMap { $0.data()["journalText"] as? String }
                        .joined(separator: " ")

                    let generatedImageURL = "https://picsum.photos/seed/\(sessionId)-final/900/900"

                    let batch = self?.db.batch()

                    batch?.updateData([
                        "status": "generated",
                        "generatedImageURL": generatedImageURL,
                        "finalPrompt": combinedPrompt,
                        "generatedAt": Timestamp(date: Date())
                    ], forDocument: sessionRef)

                    for (index, userId) in memberIds.enumerated() {
                        let pieceRef = self?.db.collection("puzzlePieces").document("\(sessionId)_piece_\(userId)")
                        let pieceImageURL = "https://picsum.photos/seed/\(sessionId)-piece-\(index)/320/320"

                        batch?.setData([
                            "pieceId": "\(sessionId)_piece_\(userId)",
                            "sessionId": sessionId,
                            "groupId": groupId,
                            "userId": userId,
                            "imageURL": pieceImageURL,
                            "index": index
                        ], forDocument: pieceRef!, merge: true)
                    }

                    batch?.commit { commitError in
                        if let commitError = commitError {
                            completion(.failure(commitError))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
        }
    }
}
