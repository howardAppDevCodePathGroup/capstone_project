import SwiftUI

struct PuzzleSubmissionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentGroupStore: CurrentGroupStore
    @StateObject private var viewModel = JournalViewModel()

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text("Puzzle Reflection")
                        .font(AppFont.hero(32))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("This is your one-time submission for the current puzzle session.")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                GlassCard {
                    VStack(spacing: 16) {
                        TextEditor(text: $viewModel.journalText)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .frame(height: 280)
                            .background(AppColors.softFill)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .foregroundStyle(AppColors.textPrimary)
                            .font(AppFont.body(18))
                            .disabled(!currentGroupStore.isFull || viewModel.hasSubmitted)

                        PrimaryButton(
                            title: viewModel.hasSubmitted ? "Already Submitted" : "Submit Puzzle Reflection",
                            icon: "arrow.up.circle.fill"
                        ) {
                            if !currentGroupStore.isFull {
                                viewModel.submitMessage = "Puzzle reflection is locked until all members have joined."
                            } else {
                                viewModel.submit(
                                    sessionId: currentGroupStore.sessionId,
                                    groupId: currentGroupStore.groupId,
                                    userId: authViewModel.currentUserId
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)

                if viewModel.isCheckingSubmission {
                    ProgressView()
                        .tint(.white)
                }

                if !viewModel.submitMessage.isEmpty {
                    Text(viewModel.submitMessage)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 10)
        }
        .navigationTitle("Puzzle Submission")
        .onAppear {
            viewModel.checkSubmissionStatus(
                sessionId: currentGroupStore.sessionId,
                userId: authViewModel.currentUserId
            )
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleSubmissionView()
            .environmentObject(AuthViewModel())
            .environmentObject(CurrentGroupStore())
    }
}
