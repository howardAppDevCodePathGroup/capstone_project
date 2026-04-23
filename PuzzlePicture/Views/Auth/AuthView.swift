import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @Namespace private var animation
    @State private var floatIcon = false

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 26) {
                Spacer()

                VStack(spacing: 14) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(.white)
                        .offset(y: floatIcon ? -6 : 6)
                        .animation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true), value: floatIcon)

                    Text(AppText.appName)
                        .font(AppFont.hero(40))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(AppText.tagline)
                        .font(AppFont.body(16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, 26)
                }

                GlassCard {
                    VStack(spacing: 20) {
                        HStack(spacing: 8) {
                            authTab(title: "Login", selected: isLoginMode) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    isLoginMode = true
                                    authViewModel.errorMessage = ""
                                }
                            }

                            authTab(title: "Sign Up", selected: !isLoginMode) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    isLoginMode = false
                                    authViewModel.errorMessage = ""
                                }
                            }
                        }
                        .padding(6)
                        .background(.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(AppFont.caption(13))
                                    .foregroundStyle(AppColors.textSecondary)

                                TextField("", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(AppFont.caption(13))
                                    .foregroundStyle(AppColors.textSecondary)

                                SecureField("", text: $password)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }

                        PrimaryButton(
                            title: isLoginMode ? "Let’s Go" : "Create Account",
                            icon: isLoginMode ? "arrow.right.circle.fill" : "person.badge.plus.fill"
                        ) {
                            if isLoginMode {
                                authViewModel.login(email: email, password: password)
                            } else {
                                authViewModel.signUp(email: email, password: password)
                            }
                        }

                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .font(AppFont.caption(14))
                                .foregroundStyle(.red.opacity(0.95))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear {
            floatIcon = true
        }
    }

    private func authTab(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.subtitle(17))
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background {
                    if selected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.accentBlue.opacity(0.55), AppColors.accentCyan.opacity(0.32)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "authTab", in: animation)
                    }
                }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
