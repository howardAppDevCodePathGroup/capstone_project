import SwiftUI

struct SubmissionStatusView: View {
    @StateObject private var viewModel = SubmissionStatusViewModel()

    let groupId: String
    let sessionId: String
    let totalMembers: Int

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 20) {
                Text("Submission Status")
                    .font(AppFont.hero(30))
                    .foregroundStyle(AppColors.textPrimary)

                GlassCard {
                    VStack(spacing: 12) {
                        Text("\(viewModel.submittedCount) / \(viewModel.totalMembers)")
                            .font(AppFont.hero(34))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("members have submitted")
                            .font(AppFont.body(16))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal)

                NavigationLink {
                    PuzzlePieceView()
                } label: {
                    Text("Continue to Puzzle Piece")
                        .font(AppFont.subtitle(17))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accentBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 40)
        }
        .onAppear {
            viewModel.startListening(groupId: groupId, sessionId: sessionId, totalMembers: totalMembers)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

#Preview {
    SubmissionStatusView(groupId: "demo_group", sessionId: "demo_session", totalMembers: 2)
}
