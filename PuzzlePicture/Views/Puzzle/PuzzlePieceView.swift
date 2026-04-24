import SwiftUI

struct PuzzlePieceView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentGroupStore: CurrentGroupStore

    @State private var piece: PuzzlePiece?
    @State private var loadMessage = ""
    @State private var isLoading = false

    private let puzzleService = PuzzleService()

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SectionHeader(
                        "Your Puzzle Piece",
                        subtitle: "This is your assigned part of the group artwork."
                    )
                    .padding(.top, 24)

                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.top, 20)
                    } else if let piece {
                        GlassCard {
                            VStack(spacing: 16) {
                                AsyncImage(url: URL(string: piece.imageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 260)
                                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    case .failure(_):
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(AppColors.softFill)
                                            .frame(height: 260)
                                            .overlay(
                                                Text("Could not load image")
                                                    .foregroundStyle(AppColors.textSecondary)
                                            )
                                    default:
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(AppColors.softFill)
                                            .frame(height: 260)
                                            .overlay(
                                                ProgressView()
                                                    .tint(.white)
                                            )
                                    }
                                }

                                Text("Piece #\(piece.index + 1)")
                                    .font(AppFont.title(22))
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("This is your assigned piece from the generated group artwork.")
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal)

                        NavigationLink {
                            FullArtworkView(sessionId: currentGroupStore.sessionId)
                        } label: {
                            Label("View Full Artwork", systemImage: "photo.on.rectangle.angled")
                                .font(AppFont.subtitle(17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.accentBlue, AppColors.accentBlueDark],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(.horizontal)

                        NavigationLink {
                            SessionSummaryView(
                                sessionId: currentGroupStore.sessionId,
                                userId: authViewModel.currentUserId
                            )
                        } label: {
                            Label("View Session Summary", systemImage: "doc.text.image")
                                .font(AppFont.subtitle(17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.accentBlueDark)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(.horizontal)

                        NavigationLink {
                            AssemblyCanvasView(sessionId: currentGroupStore.sessionId)
                        } label: {
                            Label("Open Assembly Mode", systemImage: "square.grid.2x2")
                                .font(AppFont.subtitle(17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.accentBlueDark, AppColors.accentBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(.horizontal)
                    } else {
                        GlassCard {
                            VStack(spacing: 16) {
                                Text("Your piece is not ready yet.")
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .padding(.vertical, 16)
                        }
                        .padding(.horizontal)
                    }

                    if !loadMessage.isEmpty {
                        Text(loadMessage)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Puzzle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPiece()
        }
    }

    private func loadPiece() {
        isLoading = true
        loadMessage = ""

        puzzleService.fetchPuzzlePiece(
            sessionId: currentGroupStore.sessionId,
            userId: authViewModel.currentUserId
        ) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let piece):
                    self.piece = piece
                case .failure(let error):
                    self.loadMessage = error.localizedDescription
                }
            }
        }
    }
}
