import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentGroupStore: CurrentGroupStore
    @StateObject private var groupViewModel = GroupViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroSection

                        if currentGroupStore.hasActiveGroup {
                            currentGroupCard
                        } else {
                            featuredEmptyCard
                        }

                        joinGroupCard

                        quickActionsCard

                        if !groupViewModel.statusMessage.isEmpty {
                            Text(groupViewModel.statusMessage)
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
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: Binding(
                get: { groupViewModel.hasActiveGroup },
                set: { _ in }
            )) {
                GroupLobbyView()
                    .environmentObject(currentGroupStore)
                    .environmentObject(authViewModel)
            }
            .onChange(of: groupViewModel.hasActiveGroup) {
                if groupViewModel.hasActiveGroup {
                    currentGroupStore.setGroup(
                        groupId: groupViewModel.currentGroupId,
                        sessionId: groupViewModel.currentSessionId,
                        groupName: groupViewModel.joinedGroupName.isEmpty ? "Joined Group" : groupViewModel.joinedGroupName,
                        inviteCode: groupViewModel.createdInviteCode.isEmpty ? groupViewModel.inviteCode.uppercased() : groupViewModel.createdInviteCode,
                        maxMembers: groupViewModel.joinedMaxMembers,
                        currentMemberCount: groupViewModel.currentMemberCount
                    )
                }
            }
        }
    }

    private var heroSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back")
                            .font(AppFont.hero(34))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(displayName)
                            .font(AppFont.subtitle(16))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppGradients.highlight)
                            .frame(width: 58, height: 58)

                        Image(systemName: "sparkles")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Text("Join your circle, reflect together, and turn emotions into a shared visual story.")
                    .font(AppFont.body(16))
                    .foregroundStyle(AppColors.textSecondary)

                HStack(spacing: 10) {
                    miniStat(icon: "person.3.fill", title: currentGroupStore.hasActiveGroup ? "Active Group" : "No Group")
                    miniStat(icon: "book.closed.fill", title: "Journal Ready")
                }
            }
        }
    }

    private var currentGroupCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Current Group")
                            .font(AppFont.title(24))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(currentGroupStore.groupName)
                            .font(AppFont.subtitle(18))
                            .foregroundStyle(AppColors.textSecondary)

                        Text("Invite Code: \(currentGroupStore.inviteCode)")
                            .font(AppFont.caption(13))
                            .foregroundStyle(AppColors.textMuted)
                    }

                    Spacer()

                    StatusBadge(text: "Live", color: AppColors.success)
                }

                HStack(spacing: 12) {
                    infoPill(
                        icon: "person.2.fill",
                        text: "\(currentGroupStore.currentMemberCount)/\(currentGroupStore.maxMembers) members"
                    )

                    infoPill(
                        icon: "square.and.pencil",
                        text: "Session active"
                    )
                }

                NavigationLink {
                    GroupLobbyView()
                        .environmentObject(currentGroupStore)
                        .environmentObject(authViewModel)
                } label: {
                    Label("Open Group Lobby", systemImage: "person.3.fill")
                        .font(AppFont.subtitle(18))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .fill(AppGradients.primaryButton)
                        )
                }
            }
        }
    }

    private var featuredEmptyCard: some View {
        EmptyStateView(
            icon: "person.3.sequence.fill",
            title: "No active group yet",
            subtitle: "Join with an invite code or head to Groups to create one and begin your first collaborative session."
        )
    }

    private var joinGroupCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Join with Invite Code")
                    .font(AppFont.title(24))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Have a code from your group? Enter it here and jump right in.")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.textSecondary)

                TextField("Enter invite code", text: $groupViewModel.inviteCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(AppFont.body(17))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.softFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .stroke(AppColors.stroke, lineWidth: 1)
                            )
                    )

                PrimaryButton(title: "Join Group", icon: "person.crop.circle.badge.plus") {
                    groupViewModel.joinGroup(userId: authViewModel.currentUserId)
                }
            }
        }
    }

    private var quickActionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Quick Actions")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                NavigationLink {
                    CreateJoinGroupView()
                } label: {
                    Label("Go to Groups", systemImage: "person.3")
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
                    JournalEntryView()
                        .environmentObject(authViewModel)
                        .environmentObject(currentGroupStore)
                } label: {
                    Label("Open Personal Journal", systemImage: "book.closed.fill")
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

                if currentGroupStore.hasActiveGroup {
                    NavigationLink {
                        SubmissionStatusView(
                            groupId: currentGroupStore.groupId,
                            sessionId: currentGroupStore.sessionId,
                            totalMembers: currentGroupStore.currentMemberCount
                        )
                        .environmentObject(authViewModel)
                        .environmentObject(currentGroupStore)
                    } label: {
                        Label("Open Submission Status", systemImage: "chart.bar.fill")
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
        }
    }

    private var displayName: String {
        if !authViewModel.displayName.isEmpty {
            return authViewModel.displayName
        }

        if !authViewModel.currentUserEmail.isEmpty {
            return authViewModel.currentUserEmail
        }

        return "Puzzle Picture User"
    }

    private func miniStat(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accentCyan)

            Text(title)
                .font(AppFont.caption(13))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppColors.softFill)
        )
    }

    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accentCyan)

            Text(text)
                .font(AppFont.caption(13))
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

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(CurrentGroupStore())
}
