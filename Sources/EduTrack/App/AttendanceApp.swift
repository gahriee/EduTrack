import SwiftUI
import FirebaseCore

@main
struct AttendanceApp: App {
    init() {
        if let plistPath = Bundle.module.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: plistPath) {
            FirebaseApp.configure(options: options)
        } else {
            print("⚠️ GoogleService-Info.plist not found. Firebase not configured.")
        }
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
