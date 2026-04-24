import Foundation
import Combine
import FirebaseFirestore

final class SubmissionStatusViewModel: ObservableObject {
    @Published var submittedCount: Int = 0
    @Published var totalMembers: Int = 0
    @Published var submittedUsers: [SubmittedUser] = []
    @Published var ownerId: String = ""
    @Published var sessionStatus: String = "waiting_for_members"
    @Published var generatedImageURL: String = ""
    @Published var statusStep: String = ""
    @Published var isGenerating: Bool = false
    @Published var statusMessage: String = ""

    private let journalService = JournalService()
    private let groupService = GroupService()
    private let userService = UserService()
    private let backendService = BackendService()

    private var countListener: ListenerRegistration?
    private var usersListener: ListenerRegistration?
    private var sessionListener: ListenerRegistration?

    var allSubmitted: Bool {
        totalMembers > 0 && submittedCount == totalMembers
    }

    var canOpenPuzzle: Bool {
        sessionStatus == "generated"
    }

    var shouldDisableGenerateButton: Bool {
        isGenerating || sessionStatus == "generated" || !allSubmitted
    }

    func startListening(groupId: String, sessionId: String, totalMembers: Int) {
        self.totalMembers = totalMembers

        countListener = journalService.listenForSubmissionCount(groupId: groupId, sessionId: sessionId) { [weak self] count in
            DispatchQueue.main.async {
                self?.submittedCount = count
            }
        }

        usersListener = journalService.listenForSubmittedUsers(groupId: groupId, sessionId: sessionId) { [weak self] userIds in
            guard let self else { return }

            self.userService.fetchUsers(userIds: userIds) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let users):
                        self.submittedUsers = users
                    case .failure(let error):
                        self.statusMessage = error.localizedDescription
                    }
                }
            }
        }

        sessionListener = groupService.listenToSession(sessionId: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.sessionStatus = data.status
                    self?.generatedImageURL = data.generatedImageURL
                    self?.statusStep = data.statusStep
                    self?.isGenerating = data.isGenerating
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }

        groupService.fetchGroupOwner(groupId: groupId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ownerId):
                    self?.ownerId = ownerId
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }

    func stopListening() {
        countListener?.remove()
        usersListener?.remove()
        sessionListener?.remove()
        countListener = nil
        usersListener = nil
        sessionListener = nil
    }

    func moveToGenerateStage(sessionId: String, groupId: String, currentUserId: String) {
        guard currentUserId == ownerId else {
            statusMessage = "Only the group creator can generate the image."
            return
        }

        guard allSubmitted else {
            statusMessage = "Image generation unlocks only after all members submit."
            return
        }

        guard !isGenerating else {
            statusMessage = "Generation is already in progress."
            return
        }

        guard sessionStatus != "generated" else {
            statusMessage = "Image has already been generated."
            return
        }

        statusMessage = ""

        backendService.generatePuzzleForSession(groupId: groupId, sessionId: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.statusMessage = "Generation started."
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }
}
