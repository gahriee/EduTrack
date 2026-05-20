import SwiftUI
import UniformTypeIdentifiers

struct StudentsLibraryView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingCreateStudent = false
    @State private var showingFileImporter = false
    @State private var searchText = ""
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return dataStore.students
        } else {
            return dataStore.students.filter {
                $0.firstName.localizedCaseInsensitiveContains(searchText) ||
                $0.lastName.localizedCaseInsensitiveContains(searchText) ||
                $0.studentNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(white: 0.95)
                    .edgesIgnoringSafeArea(.all)
                
                if dataStore.students.isEmpty {
                    EmptyStateView(
                        iconName: "person.2.slash",
                        title: "No Students Yet",
                        message: "Add students to your global library first."
                    )
                } else {
                    List {
                        ForEach(filteredStudents.sorted(by: { $0.lastName < $1.lastName })) { student in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(student.firstName) \(student.lastName)")
                                        .font(.headline)
                                    Text(student.studentNumber)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            let sortedStudents = filteredStudents.sorted(by: { $0.lastName < $1.lastName })
                            for index in indexSet {
                                if let id = sortedStudents[index].id {
                                    dataStore.deleteStudent(id: id)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search students")
                }
                
                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            showingCreateStudent = true
                        }
                    }
                }
            }
            .navigationTitle("Student Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingFileImporter = true }) {
                        Label("Import CSV", systemImage: "arrow.down.doc")
                    }
                }
            }
            .sheet(isPresented: $showingCreateStudent) {
                CreateStudentSheet()
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [UTType.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        do {
                            let csvData = try String(contentsOf: url, encoding: .utf8)
                            dataStore.importStudentsCSV(csvString: csvData)
                        } catch {
                            print("Error reading CSV: \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error importing file: \(error)")
                }
            }
        }
    }
}
