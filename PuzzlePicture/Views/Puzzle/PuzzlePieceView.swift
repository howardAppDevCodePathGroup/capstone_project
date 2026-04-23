import SwiftUI

struct PuzzlePieceView: View {
    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 20) {
                Text("Your Puzzle Piece")
                    .font(AppFont.hero(30))
                    .foregroundStyle(AppColors.textPrimary)

                GlassCard {
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.accentBlue.opacity(0.8), AppColors.accentCyan.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 260)
                            .overlay(
                                Text("AI Piece Placeholder")
                                    .font(AppFont.title(22))
                                    .foregroundStyle(.white)
                            )

                        Text("This is where the assigned puzzle piece will appear after AI generation.")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 40)
        }
        .navigationTitle("Puzzle")
    }
}

#Preview {
    NavigationStack {
        PuzzlePieceView()
    }
}
