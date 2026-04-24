import SwiftUI

enum AppColors {
    static let backgroundTop = Color(red: 10/255, green: 26/255, blue: 74/255)
    static let backgroundBottom = Color(red: 4/255, green: 15/255, blue: 46/255)

    static let accentBlue = Color(red: 91/255, green: 125/255, blue: 255/255)
    static let accentBlueDark = Color(red: 54/255, green: 83/255, blue: 215/255)
    static let accentCyan = Color(red: 111/255, green: 227/255, blue: 255/255)
    static let accentPurple = Color(red: 141/255, green: 116/255, blue: 255/255)
    static let accentGold = Color(red: 255/255, green: 210/255, blue: 102/255)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.82)
    static let textMuted = Color.white.opacity(0.58)

    static let cardFill = Color.white.opacity(0.10)
    static let cardFillStrong = Color.white.opacity(0.14)
    static let softFill = Color.white.opacity(0.08)
    static let stroke = Color.white.opacity(0.10)
    static let shadow = Color.black.opacity(0.24)

    static let success = Color(red: 78/255, green: 214/255, blue: 129/255)
    static let warning = Color(red: 255/255, green: 196/255, blue: 87/255)
    static let danger = Color(red: 255/255, green: 108/255, blue: 108/255)
}

enum AppSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 22
    static let xl: CGFloat = 30
    static let xxl: CGFloat = 40
}

enum AppRadius {
    static let sm: CGFloat = 14
    static let md: CGFloat = 18
    static let lg: CGFloat = 24
    static let xl: CGFloat = 30
}

enum AppFont {
    static func hero(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func title(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func subtitle(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}

enum AppGradients {
    static let background = LinearGradient(
        colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [AppColors.accentBlue, AppColors.accentBlueDark],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let highlight = LinearGradient(
        colors: [AppColors.accentPurple.opacity(0.95), AppColors.accentBlue.opacity(0.95)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let success = LinearGradient(
        colors: [AppColors.success, AppColors.accentCyan],
        startPoint: .leading,
        endPoint: .trailing
    )
}
