import Foundation
import Combine

final class JournalViewModel: ObservableObject {
    @Published var journalText: String = ""
    @Published var submitMessage: String = ""
    @Published var hasSubmitted = false
    @Published var isCheckingSubmission = false

    private let service = JournalService()

    func checkSubmissionStatus(sessionId: String, userId: String) {
        isCheckingSubmission = true

        service.checkIfUserSubmitted(sessionId: sessionId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isCheckingSubmission = false

                switch result {
                case .success(let submitted):
                    self?.hasSubmitted = submitted
                    if submitted {
                        self?.submitMessage = "You already submitted your puzzle journal for this group."
                    }
                case .failure(let error):
                    self?.submitMessage = error.localizedDescription
                }
            }
        }
    }

    func submit(sessionId: String, groupId: String, userId: String) {
        guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            submitMessage = "Please write something before submitting."
            return
        }

        guard !hasSubmitted else {
            submitMessage = "You already submitted your puzzle journal for this group."
            return
        }

        service.submitJournal(sessionId: sessionId, groupId: groupId, userId: userId, text: journalText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.submitMessage = "Puzzle journal submitted successfully."
                    self?.hasSubmitted = true
                    self?.journalText = ""
                case .failure(let error):
                    self?.submitMessage = error.localizedDescription
                }
            }
        }
    }
}
