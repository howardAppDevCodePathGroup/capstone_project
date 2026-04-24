import Foundation

struct SessionHistoryEntry: Identifiable {
    let id: String
    let sessionId: String
    let groupId: String
    let groupName: String
    let finalImageURL: String
    let pieceURL: String
    let promptTheme: String
    let createdAt: Date
}
