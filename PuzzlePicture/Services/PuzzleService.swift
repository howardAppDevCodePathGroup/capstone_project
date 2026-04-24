import Foundation
import FirebaseFirestore

final class PuzzleService {
    private let db = FirebaseManager.shared.db

    func fetchPuzzlePiece(sessionId: String, userId: String, completion: @escaping (Result<PuzzlePiece, Error>) -> Void) {
        let pieceId = "\(sessionId)_piece_\(userId)"

        db.collection("puzzlePieces").document(pieceId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                completion(.failure(NSError(domain: "PuzzleService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Puzzle piece not found."])))
                return
            }

            let piece = PuzzlePiece(
                id: data["pieceId"] as? String ?? pieceId,
                sessionId: data["sessionId"] as? String ?? sessionId,
                userId: data["userId"] as? String ?? userId,
                imageURL: data["imageURL"] as? String ?? "",
                index: data["index"] as? Int ?? 0
            )

            completion(.success(piece))
        }
    }
}
