import Foundation
import Combine

final class CurrentGroupStore: ObservableObject {
    @Published var groupId: String = ""
    @Published var sessionId: String = ""
    @Published var groupName: String = ""
    @Published var inviteCode: String = ""
    @Published var maxMembers: Int = 0
    @Published var currentMemberCount: Int = 0

    var hasActiveGroup: Bool {
        !groupId.isEmpty && !sessionId.isEmpty
    }

    var isFull: Bool {
        maxMembers > 0 && currentMemberCount >= maxMembers
    }

    func setGroup(
        groupId: String,
        sessionId: String,
        groupName: String,
        inviteCode: String,
        maxMembers: Int,
        currentMemberCount: Int = 1
    ) {
        self.groupId = groupId
        self.sessionId = sessionId
        self.groupName = groupName
        self.inviteCode = inviteCode
        self.maxMembers = maxMembers
        self.currentMemberCount = currentMemberCount
    }

    func clear() {
        groupId = ""
        sessionId = ""
        groupName = ""
        inviteCode = ""
        maxMembers = 0
        currentMemberCount = 0
    }
}
