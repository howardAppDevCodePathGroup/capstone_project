import SwiftUI

struct SubmissionStatusView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentGroupStore: CurrentGroupStore
    @StateObject private var viewModel = SubmissionStatusViewModel()

    let groupId: String
    let sessionId: String
    let totalMembers: Int

    var isOwner: Bool {
        authViewModel.currentUserId == viewModel.ownerId
    }

    var progressValue: Double {
        guard viewModel.totalMembers > 0 else { return 0 }
        return Double(viewModel.submittedCount) / Double(viewModel.totalMembers)
    }

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection

                    progressCard

                    submittedMembersCard

                    nextStageCard

                    if !viewModel.statusMessage.isEmpty {
                        Text(viewModel.statusMessage)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    if viewModel.canOpenPuzzle {
                        generatedActions
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Submission Status")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startListening(groupId: groupId, sessionId: sessionId, totalMembers: totalMembers)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    private var headerSection: some View {
        SectionHeader(
            "Submission Status",
            subtitle: "Track who has submitted and move your group toward the final artwork."
        )
    }

    private var progressCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(AppColors.softFill, lineWidth: 10)
                            .frame(width: 84, height: 84)

                        Circle()
                            .trim(from: 0, to: progressValue)
                            .stroke(
                                AppGradients.success,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 84, height: 84)

                        VStack(spacing: 2) {
                            Text("\(viewModel.submittedCount)")
                                .font(AppFont.title(24))
                                .foregroundStyle(AppColors.textPrimary)

                            Text("/ \(viewModel.totalMembers)")
                                .font(AppFont.caption(11))
                                .foregroundStyle(AppColors.textMuted)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Submission Progress")
                            .font(AppFont.title(22))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(viewModel.allSubmitted ? "All submissions are in." : "Waiting for remaining members.")
                            .font(AppFont.body(15))
                            .foregroundStyle(viewModel.allSubmitted ? AppColors.success : AppColors.textSecondary)

                        HStack(spacing: 8) {
                            StatusBadge(
                                text: prettyStatus(viewModel.sessionStatus),
                                color: badgeColor(for: viewModel.sessionStatus)
                            )

                            if viewModel.isGenerating {
                                StatusBadge(text: "In Progress", color: AppColors.warning)
                            }
                        }
                    }

                    Spacer()
                }

                if !viewModel.statusStep.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Current Step")
                                .font(AppFont.caption(12))
                                .foregroundStyle(AppColors.textMuted)

                            Spacer()

                            if viewModel.isGenerating {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.9)
                            }
                        }

                        Text(viewModel.statusStep)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.softFill.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .stroke(AppColors.stroke, lineWidth: 1)
                            )
                    )
                }
            }
        }
    }

    private var submittedMembersCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Submitted Members")
                        .font(AppFont.title(22))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Text("\(viewModel.submittedUsers.count)")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.textMuted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(AppColors.softFill)
                        )
                }

                if viewModel.submittedUsers.isEmpty {
                    EmptyStateView(
                        icon: "square.and.pencil",
                        title: "No submissions yet",
                        subtitle: "Once members submit their reflections, they will appear here."
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.submittedUsers) { user in
                            submittedUserRow(user)
                        }
                    }
                }
            }
        }
    }

    private func submittedUserRow(_ user: SubmittedUser) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppGradients.success)
                    .frame(width: 44, height: 44)

                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.textPrimary)

                if !user.email.isEmpty {
                    Text(user.email)
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.textMuted)
                }
            }

            Spacer()

            StatusBadge(text: "Submitted", color: AppColors.success)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.softFill.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.stroke, lineWidth: 1)
                )
        )
    }

    private var nextStageCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Next Stage")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)

                if viewModel.sessionStatus == "generated" {
                    Text("The artwork is ready. You can now move to the reveal flow and explore the finished session.")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.textSecondary)
                } else if viewModel.isGenerating {
                    Text("Your artwork is being created in the background. You can stay here or come back later.")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.textSecondary)
                } else if viewModel.allSubmitted {
                    if isOwner {
                        Text("All members have submitted. As the creator, you can now generate the final image.")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.textSecondary)

                        PrimaryButton(
                            title: viewModel.isGenerating ? "Generating..." : "Generate Image",
                            icon: "sparkles",
                            isDisabled: viewModel.shouldDisableGenerateButton
                        ) {
                            viewModel.moveToGenerateStage(
                                sessionId: sessionId,
                                groupId: groupId,
                                currentUserId: authViewModel.currentUserId
                            )
                        }
                    } else {
                        Text("All submissions are complete. Waiting for the group creator to generate the image.")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                } else {
                    Text("Image generation stays locked until every member submits.")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private var generatedActions: some View {
        VStack(spacing: 12) {
            NavigationLink {
                FinalRevealView(
                    sessionId: sessionId,
                    generatedImageURL: viewModel.generatedImageURL
                )
            } label: {
                Label("Open Final Reveal", systemImage: "sparkles.rectangle.stack.fill")
                    .font(AppFont.subtitle(18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppGradients.primaryButton)
                    )
            }

            NavigationLink {
                PuzzlePieceView()
                    .environmentObject(authViewModel)
                    .environmentObject(currentGroupStore)
            } label: {
                Label("Go to Puzzle Area", systemImage: "square.grid.2x2")
                    .font(AppFont.subtitle(17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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

    private func prettyStatus(_ status: String) -> String {
        switch status {
        case "waiting_for_members":
            return "Waiting for Members"
        case "collecting_journals":
            return "Collecting Journals"
        case "generating":
            return "Generating Image"
        case "generated":
            return "Generated"
        case "failed":
            return "Failed"
        default:
            return status.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private func badgeColor(for status: String) -> Color {
        switch status {
        case "generated":
            return AppColors.success
        case "generating":
            return AppColors.warning
        case "failed":
            return AppColors.danger
        default:
            return AppColors.accentBlue
        }
    }
}
