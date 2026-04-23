import SwiftUI

enum AppColors {
    static let bgTop = Color(red: 7/255, green: 16/255, blue: 34/255)
    static let bgMid = Color(red: 13/255, green: 35/255, blue: 70/255)
    static let bgBottom = Color(red: 10/255, green: 22/255, blue: 42/255)

    static let accentBlue = Color(red: 82/255, green: 132/255, blue: 255/255)
    static let accentBlueDark = Color(red: 53/255, green: 96/255, blue: 214/255)
    static let accentCyan = Color(red: 124/255, green: 223/255, blue: 255/255)

    static let card = Color.white.opacity(0.09)
    static let cardBorder = Color.white.opacity(0.12)
    static let softFill = Color.white.opacity(0.08)

    static let textPrimary = Color(red: 248/255, green: 250/255, blue: 255/255)
    static let textSecondary = Color(red: 214/255, green: 225/255, blue: 245/255)
    static let textMuted = Color(red: 176/255, green: 191/255, blue: 220/255)
}
    
enum AppText {
    static let appName = "Puzzle Picture"
    static let tagline = "Create a shared masterpiece from your group’s reflections"
}

enum AppFont {
    static func hero(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    static func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func subtitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }

    static func caption(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
}
