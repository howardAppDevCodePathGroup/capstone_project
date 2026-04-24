import SwiftUI

struct AssemblyCanvasView: View {
    let sessionId: String

    @StateObject private var viewModel = AssemblyViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SectionHeader(
                        "Assembly Mode",
                        subtitle: "Place each piece into the correct slot, then check your arrangement."
                    )
                    .padding(.top, 24)

                    if viewModel.isSolved && viewModel.didCheckAnswer {
                        solvedBanner
                    }

                    instructionsCard

                    if viewModel.isLoading {
                        LoadingStateView(
                            title: "Loading puzzle pieces...",
                            subtitle: "Preparing the puzzle board."
                        )
                        .padding(.top, 16)
                    } else {
                        boardSection
                        controlsSection
                        piecesSection
                    }

                    if !viewModel.statusMessage.isEmpty {
                        Text(viewModel.statusMessage)
                            .font(AppFont.body(14))
                            .foregroundStyle(viewModel.isSolved ? AppColors.success : AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Assembly")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load(sessionId: sessionId)
        }
    }

    private var solvedBanner: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppColors.success)

                Text("Puzzle Solved")
                    .font(AppFont.title(24))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Your arrangement is correct. You can now enjoy the completed artwork.")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                NavigationLink {
                    FullArtworkView(sessionId: sessionId)
                } label: {
                    Label("Open Full Artwork", systemImage: "photo.on.rectangle.angled")
                        .font(AppFont.subtitle(17))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .fill(AppGradients.primaryButton)
                        )
                }
            }
        }
    }

    private var instructionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("How it works")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Tap a slot on the board, then tap a piece below to place it. Tap a filled slot to remove its piece. When all slots are filled, press Check Puzzle.")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.textSecondary)

                HStack(spacing: 12) {
                    infoPill(icon: "square.grid.2x2", text: "Select Slot")
                    infoPill(icon: "hand.tap.fill", text: "Place Piece")
                    infoPill(icon: "checkmark.circle.fill", text: "Check")
                }
            }
        }
    }

    private var boardSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Puzzle Board")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(viewModel.boardSlots.enumerated()), id: \.offset) { index, piece in
                        boardSlot(index: index, piece: piece)
                    }
                }
            }
        }
    }

    private func boardSlot(index: Int, piece: DraggableAssemblyPiece?) -> some View {
        Button {
            if piece != nil {
                viewModel.removePieceFromSlot(index)
            } else {
                viewModel.selectSlot(index)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(
                        viewModel.selectedSlotIndex == index
                        ? AppColors.accentBlue.opacity(0.28)
                        : AppColors.softFill
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .stroke(
                                viewModel.selectedSlotIndex == index ? AppColors.accentCyan : AppColors.stroke,
                                lineWidth: viewModel.selectedSlotIndex == index ? 2 : 1
                            )
                    )
                    .frame(height: 180)

                if let piece {
                    AsyncImage(url: URL(string: piece.imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 168)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        case .failure(_):
                            Text("Could not load")
                                .font(AppFont.caption(12))
                                .foregroundStyle(AppColors.textSecondary)
                        default:
                            ProgressView()
                                .tint(.white)
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.square.dashed")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(AppColors.textMuted)

                        Text("Slot \(index + 1)")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.textMuted)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var controlsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Controls")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                PrimaryButton(title: "Check Puzzle", icon: "checkmark.circle.fill") {
                    viewModel.checkPuzzle()
                }

                HStack(spacing: 12) {
                    SecondaryButton(title: "Reset", icon: "arrow.counterclockwise") {
                        viewModel.resetBoard()
                    }

                    SecondaryButton(title: "Shuffle", icon: "shuffle") {
                        viewModel.shuffleAvailablePieces()
                    }
                }
            }
        }
    }

    private var piecesSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Available Pieces")
                        .font(AppFont.title(22))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Text("\(viewModel.availablePieces.count)")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.textMuted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(AppColors.softFill)
                        )
                }

                if viewModel.availablePieces.isEmpty {
                    Text("No loose pieces left. Fill the board or check your arrangement.")
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.availablePieces) { piece in
                            availablePieceCard(piece)
                        }
                    }
                }
            }
        }
    }

    private func availablePieceCard(_ piece: DraggableAssemblyPiece) -> some View {
        Button {
            viewModel.placePiece(piece)
        } label: {
            VStack(spacing: 10) {
                AsyncImage(url: URL(string: piece.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                    case .failure(_):
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.softFill)
                            .frame(height: 180)
                            .overlay(
                                Text("Could not load")
                                    .font(AppFont.caption(12))
                                    .foregroundStyle(AppColors.textSecondary)
                            )
                    default:
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.softFill)
                            .frame(height: 180)
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                            )
                    }
                }

                Text("Piece #\(piece.index + 1)")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.softFill.opacity(0.35))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.stroke, lineWidth: 1)
                    )
            )
            .shadow(color: AppColors.shadow.opacity(0.45), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accentCyan)

            Text(text)
                .font(AppFont.caption(12))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppColors.softFill)
        )
    }
}
