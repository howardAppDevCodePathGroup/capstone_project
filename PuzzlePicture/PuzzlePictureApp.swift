import SwiftUI
import FirebaseCore

@main
struct PuzzlePictureApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
