import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.headline)
                }

                Text(title)
                    .font(AppFont.subtitle(18))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [AppColors.accentBlueDark, AppColors.accentBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.13), lineWidth: 1)
            )
            .shadow(color: AppColors.accentBlue.opacity(0.22), radius: 10, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    ZStack {
        GradientBackground()
        PrimaryButton(title: "Continue", icon: "arrow.right.circle.fill") { }
            .padding()
    }
}
