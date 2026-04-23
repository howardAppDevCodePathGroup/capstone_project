import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(AppColors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.16), radius: 18, x: 0, y: 10)
    }
}

#Preview {
    ZStack {
        GradientBackground()
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Preview Card")
                    .font(AppFont.title(22))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Premium glass card")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding()
    }
}
