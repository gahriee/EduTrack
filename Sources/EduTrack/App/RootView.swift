import SwiftUI

struct RootView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        ZStack {
            Group {
                if dataStore.isInitializing {
                    SplashView()
                        .transition(.opacity)
                } else if dataStore.isAuthenticated {
                    MainTabView()
                        .transition(.opacity)
                } else {
                    AuthView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: dataStore.isInitializing)
            .animation(.easeInOut, value: dataStore.isAuthenticated)
            
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

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.accentColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Image(systemName: "graduationcap.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                Text("EduTrack")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.top, 30)
            }
        }
    }
}
