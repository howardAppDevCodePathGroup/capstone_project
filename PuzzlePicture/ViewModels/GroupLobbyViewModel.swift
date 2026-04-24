import Foundation
import Combine
import FirebaseFirestore

final class GroupLobbyViewModel: ObservableObject {
    @Published var members: [SubmittedUser] = []
    @Published var memberCount: Int = 0
    @Published var maxMembers: Int = 0
    @Published var loadMessage = ""

    private let groupService = GroupService()
    private let userService = UserService()

    private var groupListener: ListenerRegistration?
    private var memberIdsListener: ListenerRegistration?

    func startListening(groupId: String) {
        groupListener?.remove()
        memberIdsListener?.remove()

        groupListener = groupService.listenToGroup(groupId: groupId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.memberCount = data.memberCount
                    self?.maxMembers = data.maxMembers
                case .failure(let error):
                    self?.loadMessage = error.localizedDescription
                }
            }
        }

        memberIdsListener = groupService.listenToGroupMemberIds(groupId: groupId) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let ids):
                self.userService.fetchUsers(userIds: ids) { usersResult in
                    DispatchQueue.main.async {
                        switch usersResult {
                        case .success(let users):
                            self.members = users
                        case .failure(let error):
                            self.loadMessage = error.localizedDescription
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.loadMessage = error.localizedDescription
                }
            }
        }
    }

    func stopListening() {
        groupListener?.remove()
        memberIdsListener?.remove()
        groupListener = nil
        memberIdsListener = nil
    }
}
