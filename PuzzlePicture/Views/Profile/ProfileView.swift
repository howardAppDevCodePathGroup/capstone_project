import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var pulse = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.accentBlueDark, AppColors.accentBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 170)

                            HStack(alignment: .bottom, spacing: 16) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.accentBlue, AppColors.accentCyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 95, height: 95)
                                    .overlay(
                                        Image(systemName: "person.crop.circle.fill")
                                            .font(.system(size: 58))
                                            .foregroundStyle(.white)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.25), lineWidth: 2)
                                    )
                                    .scaleEffect(pulse ? 1.03 : 0.97)
                                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(authViewModel.displayName.isEmpty ? "User" : authViewModel.displayName)
                                        .font(AppFont.title(24))
                                        .foregroundStyle(.white)

                                    Text(authViewModel.currentUserEmail)
                                        .font(AppFont.body(14))
                                        .foregroundStyle(.white.opacity(0.88))
                                }

                                Spacer()
                            }
                            .padding()
                        }
                        .padding(.horizontal)

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Profile Details")
                                    .font(AppFont.title(20))
                                    .foregroundStyle(AppColors.textPrimary)

                                profileRow(label: "First Name", value: authViewModel.firstName)
                                profileRow(label: "Last Name", value: authViewModel.lastName)
                                profileRow(label: "Email", value: authViewModel.currentUserEmail)
                                profileRow(label: "Display Name", value: authViewModel.displayName)
                            }
                        }
                        .padding(.horizontal)

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Bio")
                                    .font(AppFont.title(20))
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(authViewModel.bio.isEmpty ? "No bio added yet." : authViewModel.bio)
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        .padding(.horizontal)

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Coming Soon")
                                    .font(AppFont.title(20))
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("Profile photo upload, cover photo upload, and editable profile fields can be added next.")
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        .padding(.horizontal)

                        PrimaryButton(title: "Log Out", icon: "rectangle.portrait.and.arrow.right") {
                            authViewModel.logout()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                pulse = true
            }
        }
    }

    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.caption(14))
                .foregroundStyle(AppColors.textMuted)

            Spacer()

            Text(value.isEmpty ? "—" : value)
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
