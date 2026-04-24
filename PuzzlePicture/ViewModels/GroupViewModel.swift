import Foundation
import Combine

final class GroupViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var inviteCode: String = ""
    @Published var statusMessage: String = ""

    @Published var maxMembers: Int = 2

    @Published var currentGroupId: String = ""
    @Published var currentSessionId: String = ""
    @Published var createdInviteCode: String = ""
    @Published var joinedGroupName: String = ""
    @Published var joinedMaxMembers: Int = 2
    @Published var currentMemberCount: Int = 1
    @Published var hasActiveGroup: Bool = false

    private let service = GroupService()

    func createGroup(ownerId: String) {
        let cleanName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else {
            statusMessage = "Please enter a group name."
            return
        }

        guard maxMembers >= 2 else {
            statusMessage = "A group must allow at least 2 members."
            return
        }

        service.createGroup(name: cleanName, maxMembers: maxMembers, ownerId: ownerId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.currentGroupId = data.groupId
                    self?.currentSessionId = data.sessionId
                    self?.createdInviteCode = data.inviteCode
                    self?.joinedGroupName = cleanName
                    self?.joinedMaxMembers = self?.maxMembers ?? 2
                    self?.currentMemberCount = 1
                    self?.hasActiveGroup = true
                    self?.statusMessage = "Group created successfully."
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }

    func joinGroup(userId: String) {
        let cleanCode = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard !cleanCode.isEmpty else {
            statusMessage = "Please enter an invite code."
            return
        }

        service.joinGroup(inviteCode: cleanCode, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.currentGroupId = data.groupId
                    self?.currentSessionId = data.sessionId
                    self?.joinedGroupName = data.groupName
                    self?.joinedMaxMembers = data.maxMembers
                    self?.hasActiveGroup = true
                    self?.statusMessage = "Joined group successfully."
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }
}
