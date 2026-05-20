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
        clearListeners()
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
                guard let documents = querySnapshot?.documents else { return }
                self?.classes = documents.compactMap { try? $0.data(as: SchoolClass.self) }
            }
        listeners.append(classListener)
        
        // Sections, Students, and Records would also be listened to in a real app,
        // but often it's better to fetch them as needed or listen to specific queries
        // to save reads. For this architecture, we will fetch/listen globally for simplicity.
        
        let sectionListener = db.collection("sections")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                self?.sections = documents.compactMap { try? $0.data(as: ClassSection.self) }
            }
        listeners.append(sectionListener)
        
        let studentListener = db.collection("students")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                self?.students = documents.compactMap { try? $0.data(as: Student.self) }
            }
        listeners.append(studentListener)
        
        let recordListener = db.collection("attendance_records")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                self?.attendanceRecords = documents.compactMap { try? $0.data(as: AttendanceRecord.self) }
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
    
    // MARK: - Class Operations
    func addClass(name: String, subject: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let newClass = SchoolClass(name: name, subject: subject, professorId: uid)
        do {
            let _ = try db.collection("classes").addDocument(from: newClass)
        } catch {
            print("Error adding class: \(error)")
        }
    }
    
    func deleteClass(id: String) {
        // Cascade delete: first find and delete all sections in this class
        let sectionsToDelete = sections.filter { $0.classId == id }
        for section in sectionsToDelete {
            if let sectionId = section.id {
                deleteSection(id: sectionId)
            }
        }
        
        // Delete the class itself
        db.collection("classes").document(id).delete()
    }
    
    // MARK: - Section Operations
    func addSection(name: String, classId: String) {
        let newSection = ClassSection(name: name, classId: classId, studentIds: [])
        do {
            let _ = try db.collection("sections").addDocument(from: newSection)
        } catch {
            print("Error adding section: \(error)")
        }
    }
    
    func deleteSection(id: String) {
        // Cascade delete attendance records for this section
        let recordsToDelete = attendanceRecords.filter { $0.sectionId == id }
        for record in recordsToDelete {
            if let recordId = record.id {
                db.collection("attendance_records").document(recordId).delete()
            }
        }
        // Delete the section
        db.collection("sections").document(id).delete()
    }
    
    // MARK: - Student Operations
    func createStudent(firstName: String, lastName: String, studentNumber: String, email: String) {
        let newStudent = Student(firstName: firstName, lastName: lastName, studentNumber: studentNumber, email: email)
        do {
            let _ = try db.collection("students").addDocument(from: newStudent)
        } catch {
            print("Error creating student: \(error)")
        }
    }
    
    func deleteStudent(id: String) {
        // Remove student from all sections
        for section in sections where section.studentIds.contains(id) {
            if let sectionId = section.id {
                removeStudentFromSection(studentId: id, sectionId: sectionId)
            }
        }
        
        // Delete student document
        db.collection("students").document(id).delete()
    }
    
    func addStudentToSection(studentId: String, sectionId: String) {
        guard var section = sections.first(where: { $0.id == sectionId }) else { return }
        if !section.studentIds.contains(studentId) {
            section.studentIds.append(studentId)
            do {
                try db.collection("sections").document(sectionId).setData(from: section)
            } catch {
                print("Error adding student to section: \(error)")
            }
        }
    }
    
    func removeStudentFromSection(studentId: String, sectionId: String) {
        guard var section = sections.first(where: { $0.id == sectionId }) else { return }
        section.studentIds.removeAll { $0 == studentId }
        
        do {
            try db.collection("sections").document(sectionId).setData(from: section)
            
            // Cascade delete attendance records for this student in this section
            let recordsToDelete = attendanceRecords.filter { $0.sectionId == sectionId && $0.studentId == studentId }
            for record in recordsToDelete {
                if let recordId = record.id {
                    db.collection("attendance_records").document(recordId).delete()
                }
            }
        } catch {
            print("Error removing student from section: \(error)")
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
        
        if let existing = existingRecord, let recordId = existing.id {
            // Update existing
            db.collection("attendance_records").document(recordId).updateData([
                "status": status.rawValue
            ])
        } else {
            // Create new
            let newRecord = AttendanceRecord(sectionId: sectionId, studentId: studentId, date: date, status: status)
            do {
                let _ = try db.collection("attendance_records").addDocument(from: newRecord)
            } catch {
                print("Error creating attendance record: \(error)")
            }
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
