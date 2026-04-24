import Foundation
import Combine
import FirebaseFirestore

final class FullArtworkViewModel: ObservableObject {
    @Published var session: GeneratedSession?
    @Published var isLoading = false
    @Published var statusMessage = ""

    private let service = GeneratedSessionService()
    private var listener: ListenerRegistration?

    func load(sessionId: String) {
        isLoading = true
        statusMessage = ""

        listener?.remove()
        listener = service.listenToSession(sessionId: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let session):
                    self?.session = session
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
