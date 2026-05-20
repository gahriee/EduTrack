import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingAddClass = false
    
    // Grid layout: 2 columns
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if dataStore.classes.isEmpty {
                    EmptyStateView(
                        iconName: "book.closed",
                        title: "No Classes Yet",
                        message: "Tap the + button to create your first class."
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(dataStore.classes) { schoolClass in
                                // NavigationLink to ClassDetailView (Phase 5)
                                NavigationLink(destination: ClassDetailView(schoolClass: schoolClass)) {
                                    ClassCard(schoolClass: schoolClass)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let id = schoolClass.id {
                                            dataStore.deleteClass(id: id)
                                        }
                                    } label: {
                                        Label("Delete Class", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            showingAddClass = true
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showingAddClass) {
                AddClassSheet()
            }
        }
    }
}

struct ClassCard: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "book.fill")
                .foregroundColor(.accentColor)
                .font(.title2)
                .padding(.bottom, 4)
            
            Text(schoolClass.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(schoolClass.subject)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
