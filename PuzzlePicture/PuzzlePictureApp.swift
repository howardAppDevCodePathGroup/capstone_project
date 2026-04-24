import SwiftUI
import FirebaseCore
import FirebaseFunctions

@main
struct PuzzlePictureApp: App {
    init() {
        FirebaseApp.configure()

        #if DEBUG
        let functions = Functions.functions()
        functions.useEmulator(withHost: "127.0.0.1", port: 5001)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
