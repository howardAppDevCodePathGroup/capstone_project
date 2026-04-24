import SwiftUI

struct FullArtworkView: View {
    let sessionId: String

    @StateObject private var viewModel = FullArtworkViewModel()
    @State private var showCopiedMessage = false

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    headerSection

                    if viewModel.isLoading {
                        LoadingStateView(
                            title: "Loading artwork...",
                            subtitle: "Bringing your collaborative masterpiece into view."
                        )
                        .padding(.top, 20)
                    }

                    if let session = viewModel.session {
                        artworkSection(session: session)
                        metadataSection(session: session)
                        actionSection(session: session)
                    }

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
        .navigationTitle("Artwork")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load(sessionId: sessionId)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    private var headerSection: some View {
        SectionHeader(
            "Full Artwork",
            subtitle: "This is the final image your group created together."
        )
    }

    private func artworkSection(session: GeneratedSession) -> some View {
        VStack(spacing: 14) {
            HeroArtworkCard(imageURL: session.generatedImageURL)

            HStack {
                StatusBadge(
                    text: session.status.capitalized,
                    color: badgeColor(for: session.status)
                )

                Spacer()

                if showCopiedMessage {
                    Text("Link copied")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.success)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func metadataSection(session: GeneratedSession) -> some View {
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

                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppColors.accentGold)
                }

                Divider()
                    .overlay(AppColors.softFill)

                HStack(spacing: 16) {
                    statBlock(title: "Pieces", value: "\(session.pieceCount)")
                    statBlock(title: "Session", value: String(session.sessionId.prefix(6)))
                }
            }
        }
    }

    private func actionSection(session: GeneratedSession) -> some View {
        VStack(spacing: 12) {
            if let url = URL(string: session.generatedImageURL) {
                ShareLink(item: url) {
                    Label("Share Artwork", systemImage: "square.and.arrow.up")
                        .font(AppFont.subtitle(17))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .fill(AppGradients.primaryButton)
                        )
                }

                Button {
                    UIPasteboard.general.string = session.generatedImageURL
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showCopiedMessage = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showCopiedMessage = false
                        }
                    }
                } label: {
                    Label("Copy Image Link", systemImage: "link")
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

            NavigationLink {
                AssemblyCanvasView(sessionId: session.sessionId)
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

    private func statBlock(title: String, value: String) -> some View {
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
