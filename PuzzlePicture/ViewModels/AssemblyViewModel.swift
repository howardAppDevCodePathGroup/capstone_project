import Foundation
import Combine

struct DraggableAssemblyPiece: Identifiable, Equatable {
    let id: String
    let imageURL: String
    let index: Int
    let userId: String
}

final class AssemblyViewModel: ObservableObject {
    @Published var availablePieces: [DraggableAssemblyPiece] = []
    @Published var boardSlots: [DraggableAssemblyPiece?] = []
    @Published var statusMessage = ""
    @Published var isLoading = false
    @Published var selectedSlotIndex: Int? = nil
    @Published var didCheckAnswer = false

    private let service = AssemblyService()
    private var originalPieces: [DraggableAssemblyPiece] = []

    func load(sessionId: String) {
        isLoading = true
        statusMessage = ""
        didCheckAnswer = false
        selectedSlotIndex = nil

        service.fetchAllPieces(sessionId: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let pieces):
                    let mapped = pieces.map {
                        DraggableAssemblyPiece(
                            id: $0.id,
                            imageURL: $0.imageURL,
                            index: $0.index,
                            userId: $0.userId
                        )
                    }

                    self?.originalPieces = mapped.sorted { $0.index < $1.index }
                    self?.availablePieces = mapped.shuffled()
                    self?.boardSlots = Array(repeating: nil, count: mapped.count)
                    self?.statusMessage = mapped.isEmpty ? "No puzzle pieces found for this session." : ""
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }

    func selectSlot(_ index: Int) {
        selectedSlotIndex = index
    }

    func placePiece(_ piece: DraggableAssemblyPiece) {
        guard let selectedSlotIndex else {
            statusMessage = "Select a board slot first."
            return
        }

        guard boardSlots.indices.contains(selectedSlotIndex) else { return }
        guard boardSlots[selectedSlotIndex] == nil else {
            statusMessage = "That slot is already filled."
            return
        }

        boardSlots[selectedSlotIndex] = piece
        availablePieces.removeAll { $0.id == piece.id }
        statusMessage = ""
    }

    func removePieceFromSlot(_ index: Int) {
        guard boardSlots.indices.contains(index) else { return }
        guard let piece = boardSlots[index] else { return }

        availablePieces.append(piece)
        availablePieces.sort { $0.index < $1.index }
        boardSlots[index] = nil

        if selectedSlotIndex == index {
            selectedSlotIndex = nil
        }
    }

    func shuffleAvailablePieces() {
        availablePieces.shuffle()
        statusMessage = "Pieces shuffled."
    }

    func resetBoard() {
        let returnedPieces = boardSlots.compactMap { $0 }
        availablePieces.append(contentsOf: returnedPieces)
        availablePieces.sort { $0.index < $1.index }
        boardSlots = Array(repeating: nil, count: originalPieces.count)
        selectedSlotIndex = nil
        didCheckAnswer = false
        statusMessage = "Board reset."
    }

    func checkPuzzle() {
        didCheckAnswer = true

        let allFilled = boardSlots.allSatisfy { $0 != nil }
        guard allFilled else {
            statusMessage = "Fill all slots before checking."
            return
        }

        if isSolved {
            statusMessage = "Perfect. You solved the puzzle."
        } else {
            statusMessage = "Not quite right yet. Try rearranging the pieces."
        }
    }

    var isSolved: Bool {
        guard !boardSlots.isEmpty else { return false }

        for (i, piece) in boardSlots.enumerated() {
            guard let piece else { return false }
            if piece.index != i { return false }
        }
        return true
    }

    var slotCount: Int {
        boardSlots.count
    }
}
