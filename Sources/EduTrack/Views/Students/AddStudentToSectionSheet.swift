import SwiftUI

struct AddStudentToSectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStore
    
    let section: ClassSection
    @State private var searchText = ""
    
    private var currentSection: ClassSection {
        dataStore.sections.first(where: { $0.id == section.id }) ?? section
    }
    
    var unassignedStudents: [Student] {
        dataStore.students.filter { !currentSection.studentIds.contains($0.id ?? "") }
    }
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return unassignedStudents
        } else {
            return unassignedStudents.filter {
                $0.firstName.localizedCaseInsensitiveContains(searchText) ||
                $0.lastName.localizedCaseInsensitiveContains(searchText) ||
                $0.studentNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if unassignedStudents.isEmpty {
                    Text("All students are already in this section.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(filteredStudents.sorted(by: { $0.lastName < $1.lastName })) { student in
                        Button(action: {
                            if let studentId = student.id, let sectionId = currentSection.id {
                                dataStore.addStudentToSection(studentId: studentId, sectionId: sectionId)
                            }
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(student.firstName) \(student.lastName)")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(student.studentNumber)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search students")
            .navigationTitle("Add Students")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
