import SwiftUI

struct VerifyEmailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: 24) {
                    Spacer()

                    GlassCard {
                        VStack(spacing: 18) {
                            Image(systemName: "envelope.badge")
                                .font(.system(size: 56))
                                .foregroundStyle(.white)

                            Text("Verify Your Email")
                                .font(AppFont.hero(30))
                                .foregroundStyle(AppColors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("We sent a verification link to:")
                                .font(AppFont.body(16))
                                .foregroundStyle(AppColors.textSecondary)

                            Text(authViewModel.currentUserEmail)
                                .font(AppFont.subtitle(18))
                                .foregroundStyle(AppColors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Please open your email, click the verification link, then come back and tap Refresh Status.")
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)

                            PrimaryButton(title: "Refresh Status", icon: "arrow.clockwise") {
                                authViewModel.refreshVerificationStatus()
                            }

                            PrimaryButton(title: "Resend Verification Email", icon: "paperplane.fill") {
                                authViewModel.resendVerificationEmail()
                            }

                            Button("Log Out") {
                                authViewModel.logout()
                            }
                            .foregroundStyle(.white.opacity(0.9))

                            if !authViewModel.infoMessage.isEmpty {
                                Text(authViewModel.infoMessage)
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }

                            if !authViewModel.errorMessage.isEmpty {
                                Text(authViewModel.errorMessage)
                                    .font(AppFont.body(14))
                                    .foregroundStyle(.red.opacity(0.95))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Verify Email")
        }
    }
}

#Preview {
    VerifyEmailView()
        .environmentObject(AuthViewModel())
}
