import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var pulse = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.accentBlue, AppColors.accentCyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 126, height: 126)
                            .scaleEffect(pulse ? 1.04 : 0.96)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)

                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 82))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 8) {
                        Text(authViewModel.currentUserEmail.isEmpty ? "Guest User" : authViewModel.currentUserEmail)
                            .font(AppFont.title(22))
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Level 1 Creator")
                            .font(AppFont.caption(16))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Journey")
                                .font(AppFont.title(20))
                                .foregroundStyle(AppColors.textPrimary)

                            Text("You’re building shared stories, one reflection at a time.")
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .padding(.horizontal)

                    PrimaryButton(title: "Log Out", icon: "rectangle.portrait.and.arrow.right") {
                        authViewModel.logout()
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 30)
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear {
                pulse = true
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
