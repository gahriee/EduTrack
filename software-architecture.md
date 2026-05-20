# Student Attendance App — Software Architecture

**Platform:** iOS · **Language:** Swift · **UI:** SwiftUI · **Pattern:** MVVM

---

## 1. Project Structure

```
StudentAttendance/
├── App/
│   ├── AttendanceApp.swift          # @main entry point
│   └── RootView.swift               # Auth gate → MainTabView
│
├── Models/
│   └── Models.swift                 # All data structs
│
├── Services/
│   └── DataStore.swift              # ObservableObject, single source of truth
│
├── Views/
│   ├── Auth/
│   │   └── AuthView.swift           # Login + Register
│   ├── Dashboard/
│   │   └── DashboardView.swift      # Class grid
│   ├── Classes/
│   │   └── ClassDetailView.swift    # Sections list
│   ├── Sections/
│   │   └── SectionDetailView.swift  # Students + Attendance
│   ├── Students/
│   │   ├── StudentsLibraryView.swift
│   │   ├── CreateStudentSheet.swift
│   │   └── AddStudentToSectionSheet.swift
│   └── Profile/
│       └── ProfileView.swift
│
└── Components/
    ├── FloatingActionButton.swift
    ├── EmptyStateView.swift
    ├── AuthTextField.swift
    └── AttendanceStatusPicker.swift
```

---

## 2. Data Models

```
Professor
├── id: UUID
├── name: String
├── email: String
└── password: String (hashed)

SchoolClass
├── id: UUID
├── name: String           e.g. "Mathematics 101"
├── subject: String
└── professorId: UUID      → Professor

Section
├── id: UUID
├── name: String           e.g. "Section A"
├── classId: UUID          → SchoolClass
└── studentIds: [UUID]     → [Student]

Student
├── id: UUID
├── firstName: String
├── lastName: String
├── studentNumber: String
└── email: String

AttendanceRecord
├── id: UUID
├── sectionId: UUID        → Section
├── studentId: UUID        → Student
├── date: Date
└── status: present | absent | late

AttendanceSession           (all records for one section on one date)
├── id: UUID
├── sectionId: UUID
├── date: Date
└── records: [AttendanceRecord]
```

---

## 3. State Management

A single `DataStore: ObservableObject` is injected at the root via `.environmentObject()` and consumed in any view that needs it.

```
AttendanceApp
  └── DataStore (StateObject)
        └── injected as EnvironmentObject into:
              ├── AuthView
              ├── DashboardView
              ├── ClassDetailView
              ├── SectionDetailView
              └── StudentsLibraryView
```

`DataStore` owns all CRUD operations. Views never mutate state directly — they call store methods.

---

## 4. Navigation Flow

```
RootView
  ├── [unauthenticated] → AuthView (Login / Register)
  │
  └── [authenticated] → MainTabView
        ├── Tab 1: DashboardView
        │     └── NavigationStack
        │           └── ClassDetailView (sections list)
        │                 └── SectionDetailView (students + attendance)
        │
        ├── Tab 2: StudentsLibraryView (global student pool)
        │
        └── Tab 3: ProfileView (logout)
```

---

## 5. Screen Specifications

### AuthView
- Segmented Login / Register tabs on a single card
- Login: email + password → `store.login()`
- Register: name, email, password, confirm → `store.register()`
- Error messaging inline

### DashboardView *(Classes)*
- 2-column card grid of the professor's classes
- Blank state card when empty
- Floating `+` button → `AddClassSheet` (name, subject)
- Long-press or `…` menu → delete class (cascades to sections + attendance)

### ClassDetailView *(Sections)*
- List of sections belonging to the selected class
- Floating `+` button → `AddSectionSheet` (name)
- Swipe-to-delete section (cascades to attendance)

### SectionDetailView *(Attendance)*
- **Date bar** at top — chevron navigation by day, tap to open calendar picker
- **Summary strip** — Present / Absent / Late counts for the selected date
- Student list with per-row **status picker** (segmented or menu: Present · Absent · Late)
- Swipe-to-delete removes student from section
- Toolbar `…` menu → Create New Student, Export CSV

### StudentsLibraryView
- Searchable list of all students in the global pool
- Create student → `CreateStudentSheet` (firstName, lastName, studentNumber, email)
- Assign student to a section via `AddStudentToSectionSheet`

### ProfileView
- Professor name, email
- Logout button → clears `currentProfessor`

---

## 6. Key Operations

| Operation | Store Method |
|---|---|
| Register professor | `store.register(name:email:password:)` |
| Login | `store.login(email:password:)` |
| Add class | `store.addClass(name:subject:)` |
| Delete class | `store.deleteClass(id:)` — cascades |
| Add section | `store.addSection(name:classId:)` |
| Delete section | `store.deleteSection(id:)` — cascades |
| Create student | `store.createStudent(...)` |
| Add student to section | `store.addStudentToSection(studentId:sectionId:)` |
| Remove student from section | `store.removeStudentFromSection(studentId:sectionId:)` |
| Mark attendance | `store.updateRecord(sectionId:date:studentId:status:)` |
| Import students CSV | `store.importStudentsCSV(csvString:)` |

---

## 7. Persistence & Backend

**Firebase Integration**
The app uses Firebase as its backend provider for both authentication and database.

**Authentication (Firebase Auth)**
- Handles professor registration, login, and session management.
- Secures data access rules so professors can only access their own classes.

**Database (Firestore)**
- Replaces local persistence.
- Collections: `professors`, `classes`, `sections`, `students`, `attendance_records`.
- `DataStore` acts as a repository, listening to Firestore real-time updates and converting documents to Swift models.

**Offline Support**
- Firestore's built-in offline caching ensures the app remains functional without internet, syncing when reconnected.

---

## 8. Modules & Responsibilities

| Module | Responsibility |
|---|---|
| `Models.swift` | Pure value types (structs + enums). No logic. |
| `DataStore.swift` | All business logic, CRUD, persistence, CSV export. |
| `Views/` | Presentation only. Reads from store, calls store methods. |
| `Components/` | Reusable UI pieces with no store dependency. |

---

## 9. Attendance Status

```swift
enum AttendanceStatus: String, CaseIterable {
    case present = "Present"   // ✅ green
    case absent  = "Absent"    // ❌ red
    case late    = "Late"      // 🕐 orange
}
```

Default status for unrecorded students is `.present` to speed up attendance taking (mark exceptions only).

---

## 10. Deletion Cascade Rules

```
Delete Class
  └── deletes all Sections in class
        └── deletes all AttendanceSessions for each section

Delete Section
  └── deletes all AttendanceSessions for that section

Remove Student from Section
  └── deletes AttendanceRecords for that student in that section
  └── student remains in global Students pool
```