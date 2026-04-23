import SwiftUI

struct GradientBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(AppColors.accentBlue.opacity(0.14))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -130, y: -260)

            Circle()
                .fill(AppColors.accentCyan.opacity(0.10))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(x: 140, y: 250)

            Circle()
                .fill(.white.opacity(0.04))
                .frame(width: 180, height: 180)
                .blur(radius: 50)
                .offset(x: 40, y: -20)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground()
}
