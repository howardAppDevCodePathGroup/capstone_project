import Foundation

import Combine

final class JournalViewModel: ObservableObject {
    @Published var journalText: String = ""
    @Published var submitMessage: String = ""

    private let service = JournalService()

    func submit(sessionId: String, groupId: String, userId: String) {
        guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            submitMessage = "Please write something before submitting."
            return
        }

        service.submitJournal(sessionId: sessionId, groupId: groupId, userId: userId, text: journalText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.submitMessage = "Journal submitted successfully"
                    self?.journalText = ""
                case .failure(let error):
                    self?.submitMessage = error.localizedDescription
                }
            }
        }
    }
}
