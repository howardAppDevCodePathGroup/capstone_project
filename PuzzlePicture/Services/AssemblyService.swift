import Foundation
import FirebaseFirestore

final class AssemblyService {
    private let db = FirebaseManager.shared.db

    func fetchAllPieces(sessionId: String, completion: @escaping (Result<[AssemblyPiece], Error>) -> Void) {
        db.collection("puzzlePieces")
            .whereField("sessionId", isEqualTo: sessionId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let pieces: [AssemblyPiece] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()

                    return AssemblyPiece(
                        id: doc.documentID,
                        imageURL: data["imageURL"] as? String ?? "",
                        index: data["index"] as? Int ?? 0,
                        userId: data["userId"] as? String ?? ""
                    )
                }
                .sorted { $0.index < $1.index } ?? []

                completion(.success(pieces))
            }
    }
}
