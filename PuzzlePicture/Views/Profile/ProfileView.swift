import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var pulse = false

    @State private var selectedProfilePhoto: PhotosPickerItem?
    @State private var selectedCoverPhoto: PhotosPickerItem?

    var displayName: String {
        let combined = "\(viewModel.firstName) \(viewModel.lastName)".trimmingCharacters(in: .whitespaces)
        if !combined.isEmpty { return combined }
        if !authViewModel.displayName.isEmpty { return authViewModel.displayName }
        return "Puzzle Picture User"
    }

    var displayEmail: String {
        viewModel.email.isEmpty ? authViewModel.currentUserEmail : viewModel.email
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection

                        coverAndProfileSection

                        profileStatsCard

                        detailsCard

                        bioCard

                        actionsCard

                        saveCard

                        logoutButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                pulse = true
                viewModel.loadProfile(uid: authViewModel.currentUserId)
            }
            .onChange(of: selectedProfilePhoto) {
                Task {
                    guard let item = selectedProfilePhoto else { return }
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.profileUIImage = image
                    }
                }
            }
            .onChange(of: selectedCoverPhoto) {
                Task {
                    guard let item = selectedCoverPhoto else { return }
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.coverUIImage = image
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        SectionHeader(
            "Your Profile",
            subtitle: "Customize your identity, update your bio, and keep track of your creative sessions."
        )
    }

    private var coverAndProfileSection: some View {
        ZStack(alignment: .bottomLeading) {
            coverImageView

            LinearGradient(
                colors: [.clear, .black.opacity(0.28)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 210)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))

            HStack(alignment: .bottom, spacing: 16) {
                profileImageView

                VStack(alignment: .leading, spacing: 6) {
                    Text(displayName)
                        .font(AppFont.title(26))
                        .foregroundStyle(.white)

                    Text(displayEmail)
                        .font(AppFont.body(14))
                        .foregroundStyle(.white.opacity(0.9))

                    if !viewModel.bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(viewModel.bio)
                            .font(AppFont.caption(12))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(2)
                    }
                }

                Spacer()
            }
            .padding(18)
        }
    }

    private var coverImageView: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = viewModel.coverUIImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if !viewModel.coverImageURL.isEmpty {
                    AsyncImage(url: URL(string: viewModel.coverImageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            coverPlaceholder
                        }
                    }
                } else {
                    coverPlaceholder
                }
            }
            .frame(height: 210)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))

            PhotosPicker(selection: $selectedCoverPhoto, matching: .images) {
                HStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Edit Cover")
                }
                .font(AppFont.caption(12))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.black.opacity(0.35))
                .clipShape(Capsule())
                .padding(14)
            }
        }
    }

    private var coverPlaceholder: some View {
        RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
            .fill(AppGradients.highlight)
            .overlay(
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.10))
                        .frame(width: 130, height: 130)
                        .offset(x: 110, y: -40)

                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 100, height: 100)
                        .offset(x: -120, y: 35)
                }
            )
    }

    private var profileImageView: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image = viewModel.profileUIImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if !viewModel.profileImageURL.isEmpty {
                    AsyncImage(url: URL(string: viewModel.profileImageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            profilePlaceholder
                        }
                    }
                } else {
                    profilePlaceholder
                }
            }
            .frame(width: 102, height: 102)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.28), lineWidth: 2)
            )
            .scaleEffect(pulse ? 1.03 : 0.97)
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)

            PhotosPicker(selection: $selectedProfilePhoto, matching: .images) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(AppGradients.primaryButton)
                    .clipShape(Circle())
                    .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
            }
        }
    }

    private var profilePlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [AppColors.accentBlue, AppColors.accentCyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(.white)
            )
    }

    private var profileStatsCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                statPill(icon: "sparkles", title: "Creative", subtitle: "Profile")

                statPill(icon: "book.closed.fill", title: "Journal", subtitle: "Ready")

                statPill(icon: "photo.stack.fill", title: "History", subtitle: "Saved")
            }
        }
    }

    private func statPill(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppColors.softFill)
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .foregroundStyle(AppColors.accentCyan)
            }

            Text(title)
                .font(AppFont.caption(12))
                .foregroundStyle(AppColors.textPrimary)

            Text(subtitle)
                .font(AppFont.caption(11))
                .foregroundStyle(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var detailsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Profile Details")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                inputSection(title: "First Name", text: $viewModel.firstName, placeholder: "First Name")

                inputSection(title: "Last Name", text: $viewModel.lastName, placeholder: "Last Name")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(AppFont.caption(13))
                        .foregroundStyle(AppColors.textSecondary)

                    Text(displayEmail)
                        .font(AppFont.body(16))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func inputSection(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.caption(13))
                .foregroundStyle(AppColors.textSecondary)

            TextField(placeholder, text: text)
                .font(AppFont.body(16))
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
        }
    }

    private var bioCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bio")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                TextField("Tell people a little about yourself", text: $viewModel.bio, axis: .vertical)
                    .lineLimit(4...8)
                    .font(AppFont.body(16))
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
            }
        }
    }

    private var actionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Profile Actions")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                NavigationLink {
                    SessionHistoryView()
                        .environmentObject(authViewModel)
                } label: {
                    Label("View Session History", systemImage: "clock.arrow.circlepath")
                        .font(AppFont.subtitle(17))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .fill(AppColors.accentBlueDark)
                        )
                }
            }
        }
    }

    private var saveCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                PrimaryButton(
                    title: viewModel.isLoading ? "Saving..." : "Save Profile",
                    icon: "square.and.arrow.down.fill",
                    isDisabled: viewModel.isLoading
                ) {
                    viewModel.saveProfile(uid: authViewModel.currentUserId)
                }

                if !viewModel.statusMessage.isEmpty {
                    Text(viewModel.statusMessage)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.danger)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private var logoutButton: some View {
        PrimaryButton(title: "Log Out", icon: "rectangle.portrait.and.arrow.right") {
            authViewModel.logout()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
