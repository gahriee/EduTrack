import SwiftUI

struct ClassDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    let schoolClass: SchoolClass
    
    @State private var showingAddSection = false
    
    var body: some View {
        ZStack {
            Color(white: 0.95)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Select a section below to record attendance or add students.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.98))
                
                Divider()
                
                let classSections = dataStore.sections.filter { $0.classId == schoolClass.id }
                
                if !dataStore.initialFetchSectionsDone {
                    Spacer()
                    ProgressView("Loading Sections...")
                        .padding()
                    Spacer()
                } else if classSections.isEmpty {
                    Spacer()
                    EmptyStateView(
                        iconName: "person.3.sequence.fill",
                        title: "No Sections",
                        message: "Create your first section to start taking attendance."
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(classSections) { section in
                            NavigationLink(destination: SectionDetailView(section: section)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(section.name)
                                        .font(.headline)
                                    Text("\(section.safeStudentIds.count) Students")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    if let sectionId = section.id {
                                        dataStore.deleteSection(id: sectionId)
                                    }
                                } label: {
                                    Label("Delete Section", systemImage: "trash")
                                }
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
