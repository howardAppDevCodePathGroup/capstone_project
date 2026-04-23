import SwiftUI

struct CreateJoinGroupView: View {
    @State private var inviteCode = ""

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        header

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Create a New Group")
                                    .font(AppFont.title(24))
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("Start a fresh session and invite your people.")
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.textSecondary)

                                PrimaryButton(title: "Create Group", icon: "plus.circle.fill") {
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Join with Invite Code")
                                    .font(AppFont.title(24))
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("Enter the code shared by your group.")
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.textSecondary)

                                TextField("Enter invite code", text: $inviteCode)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                                PrimaryButton(title: "Join Group", icon: "person.crop.circle.badge.plus") {
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Groups")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Build your circle")
                .font(AppFont.hero(30))
                .foregroundStyle(AppColors.textPrimary)

            Text("Create a private group or join one with an invite code.")
                .font(AppFont.body(16))
                .foregroundStyle(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CreateJoinGroupView()
}
