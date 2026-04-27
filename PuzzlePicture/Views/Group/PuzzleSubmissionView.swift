import SwiftUI

struct PuzzleSubmissionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentGroupStore: CurrentGroupStore
    @StateObject private var viewModel = JournalViewModel()

    @State private var liveMemberCount = 0
    @State private var liveMaxMembers = 0
    @State private var groupLoadMessage = ""
    @State private var isLoadingGroup = false

    private let groupService = GroupService()

    private var allMembersJoined: Bool {
        liveMaxMembers > 0 && liveMemberCount >= liveMaxMembers
    }

    private var isLocked: Bool {
        !allMembersJoined || viewModel.hasSubmitted
    }

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
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
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Group Status")
                                .font(AppFont.title(22))
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Members: \(liveMemberCount) / \(liveMaxMembers)")
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.textSecondary)

                            Text(
                                allMembersJoined
                                ? "All members joined. Puzzle reflections are unlocked."
                                : "All members must join before puzzle reflections unlock."
                            )
                            .font(AppFont.body(14))
                            .foregroundStyle(allMembersJoined ? AppColors.success : AppColors.textMuted)
                        }
                    }
                    .padding(.horizontal)

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
                                .disabled(isLocked)

                            PrimaryButton(
                                title: viewModel.hasSubmitted ? "Already Submitted" : "Submit Puzzle Reflection",
                                icon: "arrow.up.circle.fill",
                                isDisabled: isLocked || viewModel.journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ) {
                                if !allMembersJoined {
                                    viewModel.submitMessage = "Puzzle reflection is locked until all members have joined."
                                } else if viewModel.hasSubmitted {
                                    viewModel.submitMessage = "You already submitted for this session."
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

                    if isLoadingGroup || viewModel.isCheckingSubmission {
                        ProgressView()
                            .tint(.white)
                    }

                    if !groupLoadMessage.isEmpty {
                        Text(groupLoadMessage)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    if !viewModel.submitMessage.isEmpty {
                        Text(viewModel.submitMessage)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Puzzle Submission")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshGroupCounts()
            viewModel.checkSubmissionStatus(
                sessionId: currentGroupStore.sessionId,
                userId: authViewModel.currentUserId
            )
        }
    }

    private func refreshGroupCounts() {
        isLoadingGroup = true
        groupLoadMessage = ""

        groupService.fetchMemberCount(groupId: currentGroupStore.groupId) { result in
            DispatchQueue.main.async {
                isLoadingGroup = false

                switch result {
                case .success(let data):
                    liveMemberCount = data.memberCount
                    liveMaxMembers = data.maxMembers

                    currentGroupStore.currentMemberCount = data.memberCount
                    currentGroupStore.maxMembers = data.maxMembers

                case .failure(let error):
                    groupLoadMessage = error.localizedDescription
                }
            }
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
