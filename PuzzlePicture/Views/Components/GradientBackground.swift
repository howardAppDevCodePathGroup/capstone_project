import SwiftUI

struct GradientBackground: View {
    var body: some View {
        ZStack {
            AppGradients.background
                .ignoresSafeArea()

            Circle()
                .fill(AppColors.accentBlue.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: -120, y: -260)

            Circle()
                .fill(AppColors.accentPurple.opacity(0.14))
                .frame(width: 280, height: 280)
                .blur(radius: 35)
                .offset(x: 140, y: 220)

            Circle()
                .fill(AppColors.accentCyan.opacity(0.10))
                .frame(width: 220, height: 220)
                .blur(radius: 25)
                .offset(x: 120, y: -140)
        }
    }
}
