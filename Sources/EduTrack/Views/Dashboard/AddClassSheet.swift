import SwiftUI

struct AddClassSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStore
    
    @State private var className = ""
    @State private var subject = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Class Details")) {
                    TextField("Class Name (e.g. Math 101)", text: $className)
                    TextField("Subject (e.g. Mathematics)", text: $subject)
                }
            }
            .navigationTitle("New Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        dataStore.addClass(name: className, subject: subject)
                        dismiss()
                    }
                    .disabled(className.trimmingCharacters(in: .whitespaces).isEmpty || subject.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
