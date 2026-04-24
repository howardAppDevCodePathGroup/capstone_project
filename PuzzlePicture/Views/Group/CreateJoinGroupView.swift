import SwiftUI

struct CreateJoinGroupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentGroupStore: CurrentGroupStore
    @StateObject private var createJoinViewModel = GroupViewModel()
    @StateObject private var homeViewModel = HomeViewModel()

    @State private var searchText = ""

    var filteredGroups: [GroupSummary] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return homeViewModel.groups
        } else {
            return homeViewModel.groups.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.inviteCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Groups")
                                .font(AppFont.hero(30))
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Create a group, set its size, search your circles, and open any active space.")
                                .font(AppFont.body(16))
                                .foregroundStyle(AppColors.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Create a New Group")
                                    .font(AppFont.title(24))
                                    .foregroundStyle(AppColors.textPrimary)

                                TextField("Enter group name", text: $createJoinViewModel.groupName)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Maximum Members")
                                        .font(AppFont.caption(13))
                                        .foregroundStyle(AppColors.textSecondary)

                                    Stepper(value: $createJoinViewModel.maxMembers, in: 2...12) {
                                        Text("\(createJoinViewModel.maxMembers) members")
                                            .foregroundStyle(AppColors.textPrimary)
                                    }
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }

                                PrimaryButton(title: "Create Group", icon: "plus.circle.fill") {
                                    createJoinViewModel.createGroup(ownerId: authViewModel.currentUserId)
                                }

                                if !createJoinViewModel.createdInviteCode.isEmpty {
                                    Text("Invite Code: \(createJoinViewModel.createdInviteCode)")
                                        .font(AppFont.subtitle(16))
                                        .foregroundStyle(AppColors.textSecondary)
                                }

                                if !createJoinViewModel.statusMessage.isEmpty {
                                    Text(createJoinViewModel.statusMessage)
                                        .font(AppFont.body(14))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Search Groups")
                                    .font(AppFont.title(20))
                                    .foregroundStyle(AppColors.textPrimary)

                                TextField("Search by group name or invite code", text: $searchText)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }

                        if !homeViewModel.statusMessage.isEmpty {
                            Text(homeViewModel.statusMessage)
                                .font(AppFont.body(14))
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        if homeViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }

                        if !filteredGroups.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Groups")
                                    .font(AppFont.title(24))
                                    .foregroundStyle(AppColors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                ForEach(filteredGroups) { group in
                                    NavigationLink {
                                        GroupLobbyView()
                                            .environmentObject(makeStore(from: group))
                                    } label: {
                                        GlassCard {
                                            HStack(spacing: 14) {
                                                ZStack {
                                                    Circle()
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [AppColors.accentBlue, AppColors.accentCyan],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .frame(width: 54, height: 54)

                                                    Image(systemName: "person.3.fill")
                                                        .foregroundStyle(.white)
                                                }

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(group.name)
                                                        .font(AppFont.title(20))
                                                        .foregroundStyle(AppColors.textPrimary)

                                                    Text("Invite: \(group.inviteCode)")
                                                        .font(AppFont.body(14))
                                                        .foregroundStyle(AppColors.textSecondary)

                                                    Text("\(group.memberCount) / \(group.maxMembers) members")
                                                        .font(AppFont.body(13))
                                                        .foregroundStyle(group.isFull ? .green.opacity(0.9) : AppColors.textMuted)
                                                }

                                                Spacer()

                                                Image(systemName: "chevron.right")
                                                    .foregroundStyle(AppColors.textMuted)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Color.clear.frame(width: 0, height: 0)
                    }
                    .padding()
                }
            }
            .navigationTitle("Groups")
            .navigationDestination(isPresented: Binding(
                get: { createJoinViewModel.hasActiveGroup },
                set: { _ in }
            )) {
                GroupLobbyView()
                    .environmentObject(currentGroupStore)
            }
            .onAppear {
                homeViewModel.loadHome(userId: authViewModel.currentUserId)
            }
            .onChange(of: createJoinViewModel.hasActiveGroup) {
                if createJoinViewModel.hasActiveGroup {
                    currentGroupStore.setGroup(
                        groupId: createJoinViewModel.currentGroupId,
                        sessionId: createJoinViewModel.currentSessionId,
                        groupName: createJoinViewModel.joinedGroupName.isEmpty ? createJoinViewModel.groupName : createJoinViewModel.joinedGroupName,
                        inviteCode: createJoinViewModel.createdInviteCode,
                        maxMembers: createJoinViewModel.joinedMaxMembers,
                        currentMemberCount: createJoinViewModel.currentMemberCount
                    )
                }
            }
        }
    }

    private func makeStore(from group: GroupSummary) -> CurrentGroupStore {
        let store = CurrentGroupStore()
        store.setGroup(
            groupId: group.id,
            sessionId: group.currentSessionId,
            groupName: group.name,
            inviteCode: group.inviteCode,
            maxMembers: group.maxMembers,
            currentMemberCount: group.memberCount
        )
        return store
    }
}

#Preview {
    CreateJoinGroupView()
        .environmentObject(AuthViewModel())
        .environmentObject(CurrentGroupStore())
}
