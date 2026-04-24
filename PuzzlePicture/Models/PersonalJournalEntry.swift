import Foundation

struct PersonalJournalEntry: Identifiable, Codable {
    let id: String
    let userId: String
    let text: String
    let imageURL: String
    let createdAt: Date
}
