import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dataStore.currentProfessor?.name ?? "Loading...")
                                .font(.title3.weight(.semibold))
                            Text(dataStore.currentProfessor?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: {
                        do {
                            try dataStore.logout()
                        } catch {
                            print("Error logging out: \(error)")
                        }
                    }) {
                        HStack {
                            Text("Log Out")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
