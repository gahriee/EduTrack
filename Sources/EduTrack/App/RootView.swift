import SwiftUI

struct RootView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        ZStack {
            Group {
                if dataStore.isAuthenticated {
                    MainTabView()
                } else {
                    AuthView()
                }
            }
            
            // Global Loading Overlay
            if dataStore.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Please wait...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color(white: 0.2).opacity(0.8))
                    .cornerRadius(16)
                }
                .zIndex(1000) // Ensure it blocks interaction with underlying views
            }
            
            // Global Toast Overlay
            if dataStore.showGlobalToast {
                VStack {
                    Spacer()
                    Text(dataStore.globalToastMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(20)
                        .padding(.bottom, 60)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(999)
                }
                // Allow interactions with the rest of the screen
                .allowsHitTesting(false)
            }
        }
    }
}


#Preview {
    RootView()
        .environmentObject(DataStore())
}
