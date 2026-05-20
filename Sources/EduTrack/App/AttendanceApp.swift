import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        return true
    }
}

@main
struct AttendanceApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Create the single source of truth for the app's state
    // We'll define DataStore later which will integrate with Firestore
    @StateObject private var dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dataStore)
        }
    }
}
