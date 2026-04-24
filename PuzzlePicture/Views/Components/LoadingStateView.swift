import SwiftUI

struct LoadingStateView: View {
    let title: String
    let subtitle: String?

    init(title: String = "Loading...", subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)

            Text(title)
                .font(AppFont.subtitle(18))
                .foregroundStyle(AppColors.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(28)
    }
}
