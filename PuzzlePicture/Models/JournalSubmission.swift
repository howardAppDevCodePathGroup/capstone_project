import Foundation

struct JournalSubmission: Identifiable, Codable {
    let id: String
    let sessionId: String
    let groupId: String
    let userId: String
    let journalText: String
    let submittedAt: Date
}
