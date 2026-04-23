import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showCards = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Welcome back")
                                .font(AppFont.hero(34))
                                .foregroundStyle(AppColors.textPrimary)

                            Text(authViewModel.currentUserEmail.isEmpty ? "Guest User" : authViewModel.currentUserEmail)
                                .font(AppFont.caption(15))
                                .foregroundStyle(AppColors.textSecondary)

                            Text("Your next puzzle starts with one honest reflection.")
                                .font(AppFont.body(16))
                                .foregroundStyle(AppColors.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        heroCard

                        statCard(
                            title: "Group Progress",
                            subtitle: "2 of 4 members have already submitted.",
                            icon: "person.3.sequence.fill",
                            delay: 0.05
                        )

                        statCard(
                            title: "Puzzle Reward",
                            subtitle: "When everyone submits, your piece will unlock.",
                            icon: "puzzlepiece.extension.fill",
                            delay: 0.12
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
            .onAppear {
                showCards = true
            }
        }
    }

    private var heroCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today’s Session")
                            .font(AppFont.title(24))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Start your reflection and help your group reveal the image.")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.accentBlue, AppColors.accentCyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 58, height: 58)

                        Image(systemName: "sparkles")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
                }

                PrimaryButton(title: "Start Writing", icon: "arrow.right.circle.fill") {
                }
            }
        }
        .offset(y: showCards ? 0 : 20)
        .opacity(showCards ? 1 : 0)
        .animation(.spring(response: 0.62, dampingFraction: 0.83), value: showCards)
    }

    private func statCard(title: String, subtitle: String, icon: String, delay: Double) -> some View {
        GlassCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.10))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2.bold())
                        .foregroundStyle(AppColors.accentCyan)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(AppFont.title(20))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(subtitle)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }
        }
        .offset(y: showCards ? 0 : 20)
        .opacity(showCards ? 1 : 0)
        .animation(.spring(response: 0.62, dampingFraction: 0.84).delay(delay), value: showCards)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
