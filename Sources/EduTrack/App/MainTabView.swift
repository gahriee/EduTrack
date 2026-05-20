import SwiftUI

struct MainTabView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            // Dashboard (Classes) Tab
            DashboardView()
                .tabItem {
                    Label("Classes", systemImage: "rectangle.grid.2x2.fill")
                }
                .tag(0)
            
            // Students Library Tab
            StudentsLibraryView()
                .tabItem {
                    Label("Students", systemImage: "person.2.fill")
                }
                .tag(1)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
    }
}
