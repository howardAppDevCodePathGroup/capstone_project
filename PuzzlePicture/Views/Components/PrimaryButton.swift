import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isDisabled: Bool
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .bold))
                }

                Text(title)
                    .font(AppFont.subtitle(18))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppGradients.primaryButton)
                    .opacity(isDisabled ? 0.45 : 1)
            )
            .shadow(color: AppColors.accentBlue.opacity(0.25), radius: 12, x: 0, y: 8)
        }
        .disabled(isDisabled)
    }
}
