import Foundation

struct PuzzlePiece: Identifiable, Codable {
    let id: String
    let sessionId: String
    let userId: String
    let imageURL: String
    let index: Int
}
