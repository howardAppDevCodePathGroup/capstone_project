import SwiftUI

struct GroupLobbyView: View {
    @EnvironmentObject var currentGroupStore: CurrentGroupStore
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = GroupLobbyViewModel()
    @State private var copiedInvite = false

    var isFull: Bool {
        viewModel.maxMembers > 0 && viewModel.memberCount >= viewModel.maxMembers
    }

    var progressValue: Double {
        guard viewModel.maxMembers > 0 else { return 0 }
        return Double(viewModel.memberCount) / Double(viewModel.maxMembers)
    }

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    inviteCard
                    groupProgressCard
                    membersCard
                    actionsCard

                    if !viewModel.loadMessage.isEmpty {
                        Text(viewModel.loadMessage)
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
        .navigationTitle("Group Lobby")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startListening(groupId: currentGroupStore.groupId)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(currentGroupStore.groupName.isEmpty ? "Your Group" : currentGroupStore.groupName)
                .font(AppFont.hero(34))
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: 10) {
                StatusBadge(
                    text: isFull ? "Ready" : "Waiting",
                    color: isFull ? AppColors.success : AppColors.accentBlue
                )

                if authViewModel.currentUserId == firstMemberId {
                    StatusBadge(text: "Creator", color: AppColors.accentPurple)
                }
            }

            Text("This is your collaboration room. Invite members, track progress, and move to the next stage together.")
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inviteCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Invite Code")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                HStack(spacing: 12) {
                    Text(currentGroupStore.inviteCode.isEmpty ? "------" : currentGroupStore.inviteCode)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .tracking(2)

                    Spacer()

                    Button {
                        UIPasteboard.general.string = currentGroupStore.inviteCode
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            copiedInvite = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                copiedInvite = false
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: copiedInvite ? "checkmark" : "doc.on.doc")
                            Text(copiedInvite ? "Copied" : "Copy")
                        }
                        .font(AppFont.subtitle(15))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppGradients.primaryButton)
                        )
                    }
                }

                Text("Share this code so others can join your group.")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.textMuted)
            }
        }
    }

    private var groupProgressCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Group Progress")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(AppColors.softFill, lineWidth: 10)
                            .frame(width: 72, height: 72)

                        Circle()
                            .trim(from: 0, to: progressValue)
                            .stroke(
                                AppGradients.success,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 72, height: 72)

                        Text("\(viewModel.memberCount)")
                            .font(AppFont.title(22))
                            .foregroundStyle(AppColors.textPrimary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Members: \(viewModel.memberCount) / \(viewModel.maxMembers)")
                            .font(AppFont.subtitle(17))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(
                            isFull
                            ? "Everyone is here. Puzzle reflections are now unlocked."
                            : "Waiting for the remaining members to join."
                        )
                        .font(AppFont.body(14))
                        .foregroundStyle(isFull ? AppColors.success : AppColors.textMuted)
                    }

                    Spacer()
                }
            }
        }
    }

    private var membersCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Members")
                        .font(AppFont.title(22))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Text("\(viewModel.members.count)")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.textMuted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(AppColors.softFill)
                        )
                }

                if viewModel.members.isEmpty {
                    EmptyStateView(
                        icon: "person.3.sequence.fill",
                        title: "No members yet",
                        subtitle: "Once people join using your invite code, they will appear here."
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.members) { member in
                            memberRow(member)
                        }
                    }
                }
            }
        }
    }

    private func memberRow(_ member: SubmittedUser) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppGradients.primaryButton)
                    .frame(width: 44, height: 44)

                Text(initials(for: member.displayName))
                    .font(AppFont.subtitle(16))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(member.displayName)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.textPrimary)

                    if member.id == firstMemberId {
                        StatusBadge(text: "Creator", color: AppColors.accentPurple)
                    }

                    if member.id == authViewModel.currentUserId {
                        StatusBadge(text: "You", color: AppColors.accentBlue)
                    }
                }

                if !member.email.isEmpty {
                    Text(member.email)
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.textMuted)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.softFill.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.stroke, lineWidth: 1)
                )
        )
    }

    private var actionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Next Steps")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                if isFull {
                    Text("Your group is complete. Members can now submit their puzzle reflections and move toward image generation.")
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.textSecondary)

                    NavigationLink {
                        PuzzleSubmissionView()
                    } label: {
                        Label("Submit Puzzle Reflection", systemImage: "square.and.pencil")
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
                        SubmissionStatusView(
                            groupId: currentGroupStore.groupId,
                            sessionId: currentGroupStore.sessionId,
                            totalMembers: viewModel.memberCount
                        )
                        .environmentObject(currentGroupStore)
                        .environmentObject(authViewModel)
                    } label: {
                        Label("View Submission Status", systemImage: "chart.bar.fill")
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
                } else {
                    Text("Share the invite code and wait until the group reaches its full size.")
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.textSecondary)

                    SecondaryButton(title: "Copy Invite Code", icon: "doc.on.doc") {
                        UIPasteboard.general.string = currentGroupStore.inviteCode
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            copiedInvite = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                copiedInvite = false
                            }
                        }
                    }
                }
            }
        }
    }

    private var firstMemberId: String {
        viewModel.members.first?.id ?? ""
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let result = String(letters)
        return result.isEmpty ? "U" : result.uppercased()
    }
}
