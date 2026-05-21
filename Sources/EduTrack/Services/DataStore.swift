import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class DataStore: ObservableObject {
    // MARK: - Published State
    @Published var isAuthenticated: Bool = false
    @Published var currentProfessor: Professor?
    
    @Published var classes: [SchoolClass] = []
    @Published var sections: [ClassSection] = []
    @Published var students: [Student] = []
    @Published var attendanceRecords: [AttendanceRecord] = []
    
    // MARK: - Global UI State
    @Published var isLoading: Bool = false
    @Published var showGlobalToast: Bool = false
    @Published var globalToastMessage: String = ""
    
    // MARK: - Firestore & Auth References
    private let db = Firestore.firestore()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var listeners: [ListenerRegistration] = []
    
    init() {
        setupAuthListener()
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        for listener in listeners {
            listener.remove()
        }
    }
    
    // MARK: - Authentication
    private func setupAuthListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Task { @MainActor in
                guard let self = self else { return }
                if let user = user {
                    self.isAuthenticated = true
                    await self.fetchCurrentProfessor(uid: user.uid)
                    self.setupFirestoreListeners(for: user.uid)
                } else {
                    self.isAuthenticated = false
                    self.currentProfessor = nil
                    self.clearLocalData()
                    self.clearListeners()
                }
            }
        }
    }
    
    func register(name: String, email: String, password: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = authResult.user.uid
        
        let newProfessor = Professor(id: uid, name: name, email: email)
        try db.collection("professors").document(uid).setData(from: newProfessor)
        self.currentProfessor = newProfessor
    }
    
    func login(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    private func fetchCurrentProfessor(uid: String) async {
        do {
            let snapshot = try await db.collection("professors").document(uid).getDocument()
            self.currentProfessor = try snapshot.data(as: Professor.self)
        } catch {
            print("Error fetching professor: \(error)")
        }
    }
    
    // MARK: - Real-time Listeners
    private func setupFirestoreListeners(for uid: String) {
        clearListeners()
        
        // Listen to Classes
        let classListener = db.collection("classes").whereField("professorId", isEqualTo: uid)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error listening to classes: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self?.classes = documents.compactMap { doc in
                    do {
                        return try doc.data(as: SchoolClass.self)
                    } catch {
                        print("Error decoding class \(doc.documentID): \(error)")
                        return nil
                    }
                }
            }
        listeners.append(classListener)
        
        let sectionListener = db.collection("sections")
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error listening to sections: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self?.sections = documents.compactMap { doc in
                    do {
                        return try doc.data(as: ClassSection.self)
                    } catch {
                        print("Error decoding section \(doc.documentID): \(error)")
                        return nil
                    }
                }
            }
        listeners.append(sectionListener)
        
        let studentListener = db.collection("students")
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error listening to students: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self?.students = documents.compactMap { doc in
                    do {
                        return try doc.data(as: Student.self)
                    } catch {
                        print("Error decoding student \(doc.documentID): \(error)")
                        return nil
                    }
                }
            }
        listeners.append(studentListener)
        
        let recordListener = db.collection("attendance_records")
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error listening to attendance records: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self?.attendanceRecords = documents.compactMap { doc in
                    do {
                        return try doc.data(as: AttendanceRecord.self)
                    } catch {
                        print("Error decoding attendance record \(doc.documentID): \(error)")
                        return nil
                    }
                }
            }
        listeners.append(recordListener)
    }
    
    private func clearListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    
    private func clearLocalData() {
        classes = []
        sections = []
        students = []
        attendanceRecords = []
    }
    
    func showToast(message: String) {
        withAnimation {
            self.globalToastMessage = message
            self.showGlobalToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showGlobalToast = false
            }
        }
    }
    
    // MARK: - Class Operations
    func addClass(name: String, subject: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let newClass = SchoolClass(name: name, subject: subject, professorId: uid)
        self.isLoading = true
        Task {
            do {
                let _ = try await db.collection("classes").addDocument(from: newClass)
                self.showToast(message: "Class added")
            } catch {
                print("Error adding class: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func deleteClass(id: String) {
        self.isLoading = true
        Task {
            do {
                // Cascade delete: first find and delete all sections in this class
                let sectionsToDelete = self.sections.filter { $0.classId == id }
                for section in sectionsToDelete {
                    if let sectionId = section.id {
                        let recordsToDelete = self.attendanceRecords.filter { $0.sectionId == sectionId }
                        for record in recordsToDelete {
                            if let recordId = record.id { try? await self.db.collection("attendance_records").document(recordId).delete() }
                        }
                        try? await self.db.collection("sections").document(sectionId).delete()
                    }
                }
                
                // Delete the class itself
                try await self.db.collection("classes").document(id).delete()
                self.showToast(message: "Class deleted")
            } catch {
                print("Error deleting class: \(error)")
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Section Operations
    func addSection(name: String, classId: String) {
        let newSection = ClassSection(name: name, classId: classId, studentIds: [])
        self.isLoading = true
        Task {
            do {
                let _ = try await db.collection("sections").addDocument(from: newSection)
                self.showToast(message: "Section added")
            } catch {
                print("Error adding section: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func deleteSection(id: String) {
        self.isLoading = true
        Task {
            do {
                // Cascade delete attendance records for this section
                let recordsToDelete = self.attendanceRecords.filter { $0.sectionId == id }
                for record in recordsToDelete {
                    if let recordId = record.id {
                        try? await self.db.collection("attendance_records").document(recordId).delete()
                    }
                }
                // Delete the section
                try await self.db.collection("sections").document(id).delete()
                self.showToast(message: "Section deleted")
            } catch {
                print("Error deleting section: \(error)")
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Student Operations
    func createStudent(firstName: String, lastName: String, studentNumber: String, email: String) {
        let newStudent = Student(firstName: firstName, lastName: lastName, studentNumber: studentNumber, email: email)
        self.isLoading = true
        Task {
            do {
                let _ = try await db.collection("students").addDocument(from: newStudent)
                self.showToast(message: "Student created")
            } catch {
                print("Error creating student: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func deleteStudent(id: String) {
        self.isLoading = true
        Task {
            do {
                // Remove student from all sections
                for var section in self.sections where section.safeStudentIds.contains(id) {
                    if let sectionId = section.id {
                        var ids = section.safeStudentIds
                        ids.removeAll { $0 == id }
                        section.studentIds = ids
                        try? await self.db.collection("sections").document(sectionId).setData(from: section)
                        
                        let recordsToDelete = self.attendanceRecords.filter { $0.sectionId == sectionId && $0.studentId == id }
                        for record in recordsToDelete {
                            if let recordId = record.id { try? await self.db.collection("attendance_records").document(recordId).delete() }
                        }
                    }
                }
                
                // Delete student document
                try await self.db.collection("students").document(id).delete()
                self.showToast(message: "Student deleted")
            } catch {
                print("Error deleting student: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func addStudentToSection(studentId: String, sectionId: String) {
        guard var section = sections.first(where: { $0.id == sectionId }) else { return }
        var ids = section.safeStudentIds
        if !ids.contains(studentId) {
            ids.append(studentId)
            section.studentIds = ids
            self.isLoading = true
            Task {
                do {
                    try await self.db.collection("sections").document(sectionId).setData(from: section)
                    self.showToast(message: "Student added to section")
                } catch {
                    print("Error adding student to section: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    
    func removeStudentFromSection(studentId: String, sectionId: String) {
        guard var section = sections.first(where: { $0.id == sectionId }) else { return }
        var ids = section.safeStudentIds
        ids.removeAll { $0 == studentId }
        section.studentIds = ids
        
        self.isLoading = true
        Task {
            do {
                try await self.db.collection("sections").document(sectionId).setData(from: section)
                
                // Cascade delete attendance records for this student in this section
                let recordsToDelete = self.attendanceRecords.filter { $0.sectionId == sectionId && $0.studentId == studentId }
                for record in recordsToDelete {
                    if let recordId = record.id {
                        try? await self.db.collection("attendance_records").document(recordId).delete()
                    }
                }
                self.showToast(message: "Student removed from section")
            } catch {
                print("Error removing student from section: \(error)")
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Attendance Operations
    func updateRecord(sectionId: String, date: Date, studentId: String, status: AttendanceStatus) {
        // Find existing record for this student on this date in this section
        let calendar = Calendar.current
        let existingRecord = attendanceRecords.first {
            $0.sectionId == sectionId &&
            $0.studentId == studentId &&
            calendar.isDate($0.date, inSameDayAs: date)
        }
        
        self.isLoading = true
        Task {
            if let existing = existingRecord, let recordId = existing.id {
                do {
                    try await self.db.collection("attendance_records").document(recordId).updateData([
                        "status": status.rawValue
                    ])
                    self.showToast(message: "Status updated to \(status.rawValue)")
                } catch {
                    print("Error updating attendance record: \(error)")
                }
            } else {
                let newRecord = AttendanceRecord(sectionId: sectionId, studentId: studentId, date: date, status: status)
                do {
                    let _ = try await self.db.collection("attendance_records").addDocument(from: newRecord)
                    self.showToast(message: "Status updated to \(status.rawValue)")
                } catch {
                    print("Error creating attendance record: \(error)")
                }
            }
            self.isLoading = false
        }
    }
    
    func importStudentsCSV(csvString: String) {
        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 1 else { return } // Need at least one row besides header
        
        // Skip header line
        for line in lines.dropFirst() {
            let fields = line.components(separatedBy: ",")
            if fields.count >= 4 {
                let firstName = fields[0].trimmingCharacters(in: .whitespaces)
                let lastName = fields[1].trimmingCharacters(in: .whitespaces)
                let studentNumber = fields[2].trimmingCharacters(in: .whitespaces)
                let email = fields[3].trimmingCharacters(in: .whitespaces)
                
                if !firstName.isEmpty && !lastName.isEmpty {
                    createStudent(firstName: firstName, lastName: lastName, studentNumber: studentNumber, email: email)
                }
            }
        }
    }
}
