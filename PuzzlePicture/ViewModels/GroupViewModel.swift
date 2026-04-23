import Foundation

import Combine

final class GroupViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var inviteCode: String = ""
    @Published var statusMessage: String = ""
    @Published var currentGroupId: String = ""
    @Published var currentSessionId: String = ""
    @Published var createdInviteCode: String = ""

    private let service = GroupService()

    func createGroup(ownerId: String) {
        guard !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusMessage = "Please enter a group name."
            return
        }

        service.createGroup(name: groupName, ownerId: ownerId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.currentGroupId = data.groupId
                    self?.createdInviteCode = data.inviteCode
                    self?.statusMessage = "Group created. Invite code: \(data.inviteCode)"
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }

    func joinGroup(userId: String) {
        guard !inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusMessage = "Please enter an invite code."
            return
        }

        service.joinGroup(inviteCode: inviteCode, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sessionId):
                    self?.currentSessionId = sessionId
                    self?.statusMessage = "Joined group successfully"
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }
}
