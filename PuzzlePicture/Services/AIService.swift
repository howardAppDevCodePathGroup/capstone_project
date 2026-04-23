import Foundation

final class AIService {
    func generateImage(from entries: [String], completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success("https://example.com/generated-image.png"))
        }
    }
}
