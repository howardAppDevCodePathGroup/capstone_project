import SwiftUI

struct JournalEntryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = JournalViewModel()

    let sessionId = "demo_session"
    let groupId = "demo_group"

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        Text("How did today feel?")
                            .font(AppFont.hero(32))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Your words help shape the group’s final image.")
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

                            PrimaryButton(title: "Submit Entry", icon: "arrow.up.circle.fill") {
                                viewModel.submit(
                                    sessionId: sessionId,
                                    groupId: groupId,
                                    userId: authViewModel.currentUserId
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    if !viewModel.submitMessage.isEmpty {
                        Text(viewModel.submitMessage)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    NavigationLink {
                        SubmissionStatusView(groupId: groupId, sessionId: sessionId, totalMembers: 2)
                    } label: {
                        Text("View Submission Status")
                            .font(AppFont.subtitle(17))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accentBlueDark)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.top, 10)
            }
            .navigationTitle("Journal")
        }
    }
}

#Preview {
    JournalEntryView()
        .environmentObject(AuthViewModel())
}
