import SwiftUI

struct MainTabView: View {
    init() {
        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(
            red: 10/255,
            green: 20/255,
            blue: 38/255,
            alpha: 0.98
        )

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(
            red: 176/255,
            green: 191/255,
            blue: 220/255,
            alpha: 0.85
        )
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(
                red: 176/255,
                green: 191/255,
                blue: 220/255,
                alpha: 0.85
            ),
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]

        itemAppearance.selected.iconColor = UIColor.white
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 11, weight: .bold)
        ]

        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = .clear
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = .white
    }

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
    }
}

#Preview {
    MainTabView()
}
