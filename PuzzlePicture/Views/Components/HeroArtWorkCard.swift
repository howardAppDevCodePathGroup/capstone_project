import SwiftUI

struct HeroArtworkCard: View {
    let imageURL: String

    var body: some View {
        GlassCard {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                case .failure(_):
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .fill(AppColors.softFill)
                        .frame(height: 320)
                        .overlay(
                            Text("Could not load artwork")
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.textSecondary)
                        )
                default:
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .fill(AppColors.softFill)
                        .frame(height: 320)
                        .overlay(ProgressView().tint(.white))
                }
            }
        }
    }
}
