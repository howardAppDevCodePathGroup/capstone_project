import SwiftUI

struct CreateJoinGroupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = GroupViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Build your circle")
                                .font(AppFont.hero(30))
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Create a private group or join one with an invite code.")
                                .font(AppFont.body(16))
                                .foregroundStyle(AppColors.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Create a New Group")
                                    .font(AppFont.title(24))
                                    .foregroundStyle(AppColors.textPrimary)

                                TextField("Enter group name", text: $viewModel.groupName)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                                PrimaryButton(title: "Create Group", icon: "plus.circle.fill") {
                                    viewModel.createGroup(ownerId: authViewModel.currentUserId)
                                }

                                if !viewModel.createdInviteCode.isEmpty {
                                    Text("Invite Code: \(viewModel.createdInviteCode)")
                                        .font(AppFont.subtitle(16))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Join with Invite Code")
                                    .font(AppFont.title(24))
                                    .foregroundStyle(AppColors.textPrimary)

                                TextField("Enter invite code", text: $viewModel.inviteCode)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                                PrimaryButton(title: "Join Group", icon: "person.crop.circle.badge.plus") {
                                    viewModel.joinGroup(userId: authViewModel.currentUserId)
                                }
                            }
                        }

                        if !viewModel.statusMessage.isEmpty {
                            Text(viewModel.statusMessage)
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        if !viewModel.currentSessionId.isEmpty {
                            NavigationLink {
                                SubmissionStatusView(
                                    groupId: viewModel.currentGroupId.isEmpty ? "demo_group" : viewModel.currentGroupId,
                                    sessionId: viewModel.currentSessionId,
                                    totalMembers: 2
                                )
                            } label: {
                                Text("Go to Submission Status")
                                    .font(AppFont.subtitle(17))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.accentBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Groups")
        }
    }
}

#Preview {
    CreateJoinGroupView()
        .environmentObject(AuthViewModel())
}
