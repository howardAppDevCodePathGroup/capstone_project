import SwiftUI

struct JournalEntryView: View {
    @State private var journalText = ""
    @State private var didSubmit = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        Text("How did today feel?")
                            .font(AppFont.hero(32))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Your words help shape the group’s final image.")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    GlassCard {
                        VStack(spacing: 16) {
                            TextEditor(text: $journalText)
                                .scrollContentBackground(.hidden)
                                .padding(10)
                                .frame(height: 280)
                                .background(AppColors.softFill)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .foregroundStyle(AppColors.textPrimary)
                                .font(AppFont.body(18))

                            PrimaryButton(
                                title: didSubmit ? "Entry Submitted" : "Submit Entry",
                                icon: didSubmit ? "checkmark.circle.fill" : "arrow.up.circle.fill"
                            ) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                                    didSubmit = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 10)
            }
            .navigationTitle("Journal")
        }
    }
}

#Preview {
    JournalEntryView()
}
