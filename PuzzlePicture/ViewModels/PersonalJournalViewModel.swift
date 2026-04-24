import Foundation
import Combine
import UIKit
import FirebaseFirestore

final class PersonalJournalViewModel: ObservableObject {
    @Published var journalText: String = ""
    @Published var selectedImage: UIImage?
    @Published var entries: [PersonalJournalEntry] = []
    @Published var statusMessage: String = ""
    @Published var isSaving = false

    private let service = PersonalJournalService()
    private var listener: ListenerRegistration?

    func saveEntry(userId: String) {
        let cleanText = journalText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanText.isEmpty else {
            statusMessage = "Please write something before saving."
            return
        }

        isSaving = true
        statusMessage = ""

        service.saveEntry(userId: userId, text: cleanText, image: selectedImage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSaving = false

                switch result {
                case .success:
                    self?.journalText = ""
                    self?.selectedImage = nil
                    self?.statusMessage = "Personal journal saved."
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }

    func startListening(userId: String) {
        listener?.remove()
        listener = service.listenToEntries(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.entries = entries
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
