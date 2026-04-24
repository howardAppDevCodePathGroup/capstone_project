import SwiftUI

struct SessionSummaryView: View {
    let sessionId: String
    let userId: String

    @StateObject private var viewModel = SessionSummaryViewModel()

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection

                    if viewModel.isLoading {
                        LoadingStateView(
                            title: "Loading summary...",
                            subtitle: "Gathering your session details and assigned piece."
                        )
                        .padding(.top, 20)
                    }

                    if let session = viewModel.session {
                        summaryOverviewCard(session: session)

                        if !session.generatedImageURL.isEmpty {
                            HeroArtworkCard(imageURL: session.generatedImageURL)
                        }
                    }

                    if let piece = viewModel.piece {
                        userPieceCard(piece)
                    }

                    actionButtons

                    if !viewModel.statusMessage.isEmpty {
                        Text(viewModel.statusMessage)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load(sessionId: sessionId, userId: userId)
        }
    }

    private var headerSection: some View {
        SectionHeader(
            "Session Summary",
            subtitle: "A polished recap of your group’s completed puzzle session."
        )
    }

    private func summaryOverviewCard(session: GeneratedSession) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.groupName)
                            .font(AppFont.title(26))
                            .foregroundStyle(AppColors.textPrimary)

                        if !session.promptTheme.isEmpty {
                            Text(session.promptTheme)
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    StatusBadge(
                        text: session.status.capitalized,
                        color: badgeColor(for: session.status)
                    )
                }

                Divider()
                    .overlay(AppColors.softFill)

                HStack(spacing: 16) {
                    summaryMetric("Pieces", "\(session.pieceCount)")
                    summaryMetric("Session", String(session.sessionId.prefix(6)))
                }
            }
        }
    }

    private func userPieceCard(_ piece: PuzzlePiece) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Your Assigned Piece")
                        .font(AppFont.title(22))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    StatusBadge(text: "Piece #\(piece.index + 1)", color: AppColors.accentPurple)
                }

                AsyncImage(url: URL(string: piece.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                    case .failure(_):
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.softFill)
                            .frame(height: 240)
                            .overlay(
                                Text("Could not load piece")
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColors.textSecondary)
                            )
                    default:
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.softFill)
                            .frame(height: 240)
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                            )
                    }
                }

                Text("This was the section of the final artwork assigned specifically to you.")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
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

            NavigationLink {
                AssemblyCanvasView(sessionId: sessionId)
            } label: {
                Label("Open Assembly Mode", systemImage: "square.grid.2x2")
                    .font(AppFont.subtitle(17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.softFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .stroke(AppColors.stroke, lineWidth: 1)
                            )
                    )
            }
        }
    }

    private func summaryMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFont.caption(12))
                .foregroundStyle(AppColors.textMuted)

            Text(value)
                .font(AppFont.title(20))
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func badgeColor(for status: String) -> Color {
        switch status.lowercased() {
        case "generated":
            return AppColors.success
        case "generating":
            return AppColors.warning
        case "failed":
            return AppColors.danger
        default:
            return AppColors.accentBlue
        }
    }
}
