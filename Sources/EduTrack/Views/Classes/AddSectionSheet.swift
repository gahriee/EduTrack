import SwiftUI

struct AddSectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStore
    
    let classId: String
    @State private var sectionName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Section Details")) {
                    TextField("Section Name (e.g. Section A)", text: $sectionName)
                }
            }
            .navigationTitle("New Section")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        dataStore.addSection(name: sectionName, classId: classId)
                        dismiss()
                    }
                    .disabled(sectionName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
