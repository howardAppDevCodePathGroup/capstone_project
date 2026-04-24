import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            CreateJoinGroupView()
                .tabItem {
                    Label("Groups", systemImage: "person.3.fill")
                }

            JournalEntryView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "sparkles")
                }
        }
        .tint(.white)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(AppColors.backgroundBottom.opacity(0.78))

        let normalIconColor = UIColor(AppColors.textMuted)
        let selectedIconColor = UIColor.white

        let normalTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: normalIconColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]

        let selectedTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedIconColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .bold)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = normalIconColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalTitleAttributes

        appearance.stackedLayoutAppearance.selected.iconColor = selectedIconColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTitleAttributes

        appearance.inlineLayoutAppearance.normal.iconColor = normalIconColor
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalTitleAttributes
        appearance.inlineLayoutAppearance.selected.iconColor = selectedIconColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedTitleAttributes

        appearance.compactInlineLayoutAppearance.normal.iconColor = normalIconColor
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalTitleAttributes
        appearance.compactInlineLayoutAppearance.selected.iconColor = selectedIconColor
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedTitleAttributes

        appearance.shadowColor = UIColor.clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }
}
