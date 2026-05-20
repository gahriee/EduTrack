import SwiftUI

struct ClassDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    let schoolClass: SchoolClass
    
    @State private var showingAddSection = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            let classSections = dataStore.sections.filter { $0.classId == schoolClass.id }
            
            if classSections.isEmpty {
                EmptyStateView(
                    iconName: "person.3.sequence.fill",
                    title: "No Sections",
                    message: "Create your first section to start taking attendance."
                )
            } else {
                List {
                    ForEach(classSections) { section in
                        NavigationLink(destination: SectionDetailView(section: section)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(section.name)
                                    .font(.headline)
                                Text("\(section.studentIds.count) Students")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            if let sectionId = classSections[index].id {
                                dataStore.deleteSection(id: sectionId)
                            }
                        }
                    }
                }
            }
            
            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton {
                        showingAddSection = true
                    }
                }
            }
        }
        .navigationTitle(schoolClass.name)
        .sheet(isPresented: $showingAddSection) {
            if let classId = schoolClass.id {
                AddSectionSheet(classId: classId)
            }
        }
    }
}
