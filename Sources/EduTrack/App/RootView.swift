import SwiftUI

struct RootView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        Group {
            // Depending on the authentication state from DataStore,
            // we route the user to either the Auth flow or the Main app flow.
            // When using Firebase Auth, dataStore will listen to Auth.auth().addStateDidChangeListener
            if dataStore.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}


#Preview {
    RootView()
        .environmentObject(DataStore())
}
