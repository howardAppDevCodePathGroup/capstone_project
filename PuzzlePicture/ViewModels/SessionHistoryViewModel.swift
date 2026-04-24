import Foundation
import Combine
import FirebaseFirestore

final class SessionHistoryViewModel: ObservableObject {
    @Published var items: [SessionHistoryEntry] = []
    @Published var statusMessage = ""

    private let service = SessionHistoryService()
    private var listener: ListenerRegistration?

    func startListening(userId: String) {
        listener?.remove()
        listener = service.listenToHistory(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.items = items
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
