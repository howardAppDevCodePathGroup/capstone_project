
import Foundation
import Combine
import FirebaseFirestore

final class SessionSummaryViewModel: ObservableObject {
    @Published var session: GeneratedSession?
    @Published var piece: PuzzlePiece?
    @Published var statusMessage = ""
    @Published var isLoading = false

    private let sessionService = GeneratedSessionService()
    private let puzzleService = PuzzleService()

    func load(sessionId: String, userId: String) {
        isLoading = true
        statusMessage = ""

        sessionService.fetchSession(sessionId: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let session):
                    self?.session = session
                    self?.loadPiece(sessionId: sessionId, userId: userId)
                case .failure(let error):
                    self?.isLoading = false
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadPiece(sessionId: String, userId: String) {
        puzzleService.fetchPuzzlePiece(sessionId: sessionId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let piece):
                    self?.piece = piece
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }
}
