import SwiftUI

struct FinalRevealView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    let sessionId: String
    let generatedImageURL: String

    @State private var animateHero = false

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    celebrationHeader

                    HeroArtworkCard(imageURL: generatedImageURL)
                        .scaleEffect(animateHero ? 1.0 : 0.96)
                        .opacity(animateHero ? 1.0 : 0.75)
                        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: animateHero)

                    successCard

                    actionButtons
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Final Reveal")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateHero = true
        }
    }

    private var celebrationHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.accentGold.opacity(0.18))
                    .frame(width: 78, height: 78)

                Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(AppColors.accentGold)
            }

            Text("Your Group Artwork Is Ready")
                .font(AppFont.hero(34))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Your reflections came together to create one final image. Explore the artwork, assemble the puzzle, or continue into the full session flow.")
                .font(AppFont.body(16))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var successCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppGradients.success)
                            .frame(width: 44, height: 44)

                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Generation Complete")
                            .font(AppFont.subtitle(18))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Your group session has successfully turned into a complete collaborative artwork.")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()
                }

                HStack(spacing: 12) {
                    infoPill(icon: "photo.fill", text: "Artwork Ready")
                    infoPill(icon: "square.grid.2x2.fill", text: "Puzzle Active")
                    infoPill(icon: "clock.arrow.circlepath", text: "Saved to History")
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink {
                FullArtworkView(sessionId: sessionId)
            } label: {
                Label("Open Full Artwork", systemImage: "photo.on.rectangle.angled")
                    .font(AppFont.subtitle(18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppGradients.primaryButton)
                    )
            }

            NavigationLink {
                PuzzlePieceView()
            } label: {
                Label("View My Puzzle Piece", systemImage: "square.fill")
                    .font(AppFont.subtitle(17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.accentBlueDark)
                    )
            }

            NavigationLink {
                SessionSummaryView(sessionId: sessionId, userId: authViewModel.currentUserId)
            } label: {
                Label("Open Session Summary", systemImage: "doc.text.image")
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
