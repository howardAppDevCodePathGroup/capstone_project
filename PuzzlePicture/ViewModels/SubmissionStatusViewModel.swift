import Foundation

import Combine

import FirebaseFirestore

final class SubmissionStatusViewModel: ObservableObject {
    @Published var submittedCount: Int = 0
    @Published var totalMembers: Int = 0

    private let service = JournalService()
    private var listener: ListenerRegistration?

    func startListening(groupId: String, sessionId: String, totalMembers: Int) {
        self.totalMembers = totalMembers

        listener = service.listenForSubmissionCount(groupId: groupId, sessionId: sessionId) { [weak self] count in
            DispatchQueue.main.async {
                self?.submittedCount = count
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
