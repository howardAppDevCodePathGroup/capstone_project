import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(AppColors.accentCyan)

                Text(title)
                    .font(AppFont.title(24))
                    .foregroundStyle(AppColors.textPrimary)

                Text(subtitle)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 14)
        }
    }
}
