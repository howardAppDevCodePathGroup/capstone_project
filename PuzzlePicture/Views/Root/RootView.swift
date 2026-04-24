import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var currentGroupStore = CurrentGroupStore()

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                if authViewModel.isEmailVerified {
                    MainTabView()
                        .environmentObject(authViewModel)
                        .environmentObject(currentGroupStore)
                } else {
                    VerifyEmailView()
                        .environmentObject(authViewModel)
                        .environmentObject(currentGroupStore)
                }
            } else {
                AuthView()
                    .environmentObject(authViewModel)
                    .environmentObject(currentGroupStore)
            }
        }
    }
}

#Preview {
    RootView()
}
