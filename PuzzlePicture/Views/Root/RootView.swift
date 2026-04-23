import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                if authViewModel.isEmailVerified {
                    MainTabView()
                        .environmentObject(authViewModel)
                } else {
                    VerifyEmailView()
                        .environmentObject(authViewModel)
                }
            } else {
                AuthView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    RootView()
}
