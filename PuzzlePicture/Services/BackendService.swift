import Foundation
import FirebaseFunctions

final class BackendService {
    private let functions = Functions.functions()

    func generatePuzzleForSession(
        groupId: String,
        sessionId: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        functions.httpsCallable("generatePuzzleForSession").call([
            "groupId": groupId,
            "sessionId": sessionId
        ]) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let data = result?.data as? [String: Any] ?? [:]
            completion(.success(data))
        }
    }
}
