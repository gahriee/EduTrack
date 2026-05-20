import SwiftUI

struct CreateStudentSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStore
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var studentNumber = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Student Details")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Student Number / ID", text: $studentNumber)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("New Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        dataStore.createStudent(firstName: firstName, lastName: lastName, studentNumber: studentNumber, email: email)
                        dismiss()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || studentNumber.isEmpty)
                }
            }
        }
    }
}
