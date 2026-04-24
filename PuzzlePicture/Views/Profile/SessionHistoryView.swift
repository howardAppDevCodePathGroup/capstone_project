import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SessionHistoryViewModel()

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    headerSection

                    if !viewModel.statusMessage.isEmpty {
                        messageView(viewModel.statusMessage)
                    }

                    if viewModel.items.isEmpty {
                        emptyStateView
                    } else {
                        historyGrid
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startListening(userId: authViewModel.currentUserId)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    private var headerSection: some View {
        SectionHeader(
            "Session History",
            subtitle: "Browse your past collaborative artwork and reopen completed sessions."
        )
    }

    private func messageView(_ message: String) -> some View {
        Text(message)
            .font(AppFont.body(14))
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    private var emptyStateView: some View {
        EmptyStateView(
            icon: "photo.stack.fill",
            title: "No sessions yet",
            subtitle: "Once your group completes a generated session, it will appear here as part of your personal gallery."
        )
    }

    private var historyGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(viewModel.items) { item in
                NavigationLink {
                    SessionSummaryView(
                        sessionId: item.sessionId,
                        userId: authViewModel.currentUserId
                    )
                } label: {
                    historyCard(for: item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func historyCard(for item: SessionHistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            cardImage(for: item)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(item.groupName)
                        .font(AppFont.subtitle(16))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    StatusBadge(text: "Saved", color: AppColors.success)
                }

                Text(item.promptTheme.isEmpty ? "Generated artwork" : item.promptTheme)
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)

                HStack {
                    Label(formattedDate(item.createdAt), systemImage: "calendar")
                        .font(AppFont.caption(11))
                        .foregroundStyle(AppColors.textMuted)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.textMuted)
                }
            }
        }
        .padding(12)
        .background(cardBackground)
        .shadow(color: AppColors.shadow.opacity(0.55), radius: 16, x: 0, y: 10)
    }

    private func cardImage(for item: SessionHistoryEntry) -> some View {
        AsyncImage(url: URL(string: item.finalImageURL)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            case .failure(_):
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.softFill)
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(AppColors.textMuted)
                    )
            default:
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.softFill)
                    .frame(height: 180)
                    .overlay(
                        ProgressView()
                            .tint(.white)
                    )
            }
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(AppColors.softFill.opacity(0.35))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AppColors.stroke, lineWidth: 1)
            )
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
