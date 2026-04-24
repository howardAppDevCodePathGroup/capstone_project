import SwiftUI

struct StatusBadge: View {
    let text: String
    var color: Color = AppColors.accentBlue

    var body: some View {
        Text(text)
            .font(AppFont.caption(12))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}
