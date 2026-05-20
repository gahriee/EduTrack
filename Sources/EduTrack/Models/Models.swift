import Foundation
import FirebaseFirestore

// -------------------------------------------------------------------------
// Professor
// -------------------------------------------------------------------------
struct Professor: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var email: String
}

// -------------------------------------------------------------------------
// SchoolClass
// -------------------------------------------------------------------------
struct SchoolClass: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var subject: String
    var professorId: String
}

// -------------------------------------------------------------------------
// ClassSection
// -------------------------------------------------------------------------
struct ClassSection: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var classId: String
    var studentIds: [String]
}

// -------------------------------------------------------------------------
// Student
// -------------------------------------------------------------------------
struct Student: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var studentNumber: String
    var email: String
}

// -------------------------------------------------------------------------
// AttendanceStatus
// -------------------------------------------------------------------------
enum AttendanceStatus: String, CaseIterable, Codable, Hashable {
    case present = "Present"
    case absent = "Absent"
    case late = "Late"
}

// -------------------------------------------------------------------------
// AttendanceRecord
// -------------------------------------------------------------------------
struct AttendanceRecord: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var sectionId: String
    var studentId: String
    var date: Date
    var status: AttendanceStatus
}

// -------------------------------------------------------------------------
// AttendanceSession
// -------------------------------------------------------------------------
struct AttendanceSession: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var sectionId: String
    var date: Date
    var records: [AttendanceRecord]
}
