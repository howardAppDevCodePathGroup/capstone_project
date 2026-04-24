import SwiftUI
import PhotosUI

struct JournalEntryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = PersonalJournalViewModel()

    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(spacing: 8) {
                            Text("Personal Journal")
                                .font(AppFont.hero(32))
                                .foregroundStyle(AppColors.textPrimary)

                            Text("This is your private journal. It is separate from puzzle submissions.")
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        GlassCard {
                            VStack(spacing: 16) {
                                TextField("Write your thoughts...", text: $viewModel.journalText, axis: .vertical)
                                    .lineLimit(6...12)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.softFill)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                                if let image = viewModel.selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }

                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    Text("Attach Image")
                                        .font(AppFont.subtitle(16))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppColors.accentBlueDark)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }

                                PrimaryButton(
                                    title: viewModel.isSaving ? "Saving..." : "Save Journal Entry",
                                    icon: "square.and.arrow.down.fill"
                                ) {
                                    viewModel.saveEntry(userId: authViewModel.currentUserId)
                                }
                            }
                        }
                        .padding(.horizontal)

                        if !viewModel.statusMessage.isEmpty {
                            Text(viewModel.statusMessage)
                                .font(AppFont.body(14))
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Entries")
                                .font(AppFont.title(24))
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(viewModel.entries) { entry in
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(entry.text)
                                            .font(AppFont.body(15))
                                            .foregroundStyle(AppColors.textPrimary)

                                        if !entry.imageURL.isEmpty {
                                            AsyncImage(url: URL(string: entry.imageURL)) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxHeight: 220)
                                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                default:
                                                    EmptyView()
                                                }
                                            }
                                        }

                                        Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(AppFont.caption(12))
                                            .foregroundStyle(AppColors.textMuted)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Journal")
            .onAppear {
                viewModel.startListening(userId: authViewModel.currentUserId)
            }
            .onDisappear {
                viewModel.stopListening()
            }
            .onChange(of: selectedPhoto) {
                Task {
                    guard let item = selectedPhoto else { return }
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.selectedImage = image
                    }
                }
            }
        }
    }
}
