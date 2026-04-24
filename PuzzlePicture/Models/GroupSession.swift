import Foundation

struct GroupSession: Identifiable, Codable {
    let id: String
    let groupId: String
    var name: String
    var inviteCode: String
    var ownerId: String
    var memberIds: [String]
    var maxMembers: Int
    var currentSessionId: String
}
