import SwiftUI
import FirebaseCore

@main
struct AttendanceApp: App {
    init() {
        FirebaseApp.configure()
    }
    
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
