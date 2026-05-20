# EduTrack — Project Status

**Platform:** iOS · **Language:** Swift · **UI:** SwiftUI · **Pattern:** MVVM  
**Backend:** Firebase Auth + Firestore

Last Updated: 2026-05-21

---

## Legend
- `[ ]` Not started
- `[/]` In progress
- `[x]` Done

---

## 1. Project Setup

| Task | Status |
|---|---|
| Swift Package created | `[x]` |
| `Package.swift` configured (iOS 15+, macOS 13+) | `[x]` |
| Firebase SDK dependencies added (`FirebaseAuth`, `FirebaseFirestore`) | `[x]` |
| `GoogleService-Info.plist` added to project | `[x]` |
| Firebase project created in Firebase Console | `[x]` |
| Firestore security rules configured | `[x]` |

---

## 2. Project Structure

| Folder | Status |
|---|---|
| `App/` | `[x]` |
| `Models/` | `[x]` (folder only) |
| `Services/` | `[x]` (folder only) |
| `Views/Auth/` | `[x]` (folder only) |
| `Views/Dashboard/` | `[x]` (folder only) |
| `Views/Classes/` | `[x]` (folder only) |
| `Views/Sections/` | `[x]` (folder only) |
| `Views/Students/` | `[x]` (folder only) |
| `Views/Profile/` | `[x]` (folder only) |
| `Components/` | `[x]` (folder only) |

---

## 3. App Layer (`App/`)

| File | Description | Status |
|---|---|---|
| `AttendanceApp.swift` | `@main` entry point, Firebase init via `AppDelegate` | `[x]` |
| `RootView.swift` | Auth gate → routes to `AuthView` or `MainTabView` | `[x]` |

---

## 4. Data Models (`Models/`)

| Model | Fields | Status |
|---|---|---|
| `Professor` | `id`, `name`, `email` | `[x]` |
| `SchoolClass` | `id`, `name`, `subject`, `professorId` | `[x]` |
| `Section` | `id`, `name`, `classId`, `studentIds` | `[x]` |
| `Student` | `id`, `firstName`, `lastName`, `studentNumber`, `email` | `[x]` |
| `AttendanceRecord` | `id`, `sectionId`, `studentId`, `date`, `status` | `[x]` |
| `AttendanceSession` | `id`, `sectionId`, `date`, `records` | `[x]` |
| `AttendanceStatus` (enum) | `present`, `absent`, `late` | `[x]` |

---

## 5. Services (`Services/`)

| File | Responsibility | Status |
|---|---|---|
| `DataStore.swift` | `ObservableObject`, Firebase Auth listener, Firestore CRUD | `[x]` |

### DataStore Operations

| Operation | Method | Status |
|---|---|---|
| Register professor | `store.register(name:email:password:)` | `[x]` |
| Login | `store.login(email:password:)` | `[x]` |
| Logout | `store.logout()` | `[x]` |
| Add class | `store.addClass(name:subject:)` | `[x]` |
| Delete class (cascade) | `store.deleteClass(id:)` | `[x]` |
| Add section | `store.addSection(name:classId:)` | `[x]` |
| Delete section (cascade) | `store.deleteSection(id:)` | `[x]` |
| Create student | `store.createStudent(...)` | `[x]` |
| Add student to section | `store.addStudentToSection(studentId:sectionId:)` | `[x]` |
| Remove student from section | `store.removeStudentFromSection(studentId:sectionId:)` | `[x]` |
| Mark attendance | `store.updateRecord(sectionId:date:studentId:status:)` | `[x]` |
| Import students CSV | `store.importStudentsCSV(csvString:)` | `[x]` |

---

## 6. Views

### Auth (`Views/Auth/`)
| File | Description | Status |
|---|---|---|
| `AuthView.swift` | Segmented Login / Register card, inline error messages | `[x]` |

### Dashboard (`Views/Dashboard/`)
| File | Description | Status |
|---|---|---|
| `DashboardView.swift` | 2-column class grid, FAB to add class, long-press to delete | `[x]` |
| `AddClassSheet.swift` | Sheet to create a new class (name, subject) | `[x]` |

### Classes (`Views/Classes/`)
| File | Description | Status |
|---|---|---|
| `ClassDetailView.swift` | List of sections, FAB to add section, swipe-to-delete | `[x]` |
| `AddSectionSheet.swift` | Sheet to create a new section (name) | `[x]` |

### Sections (`Views/Sections/`)
| File | Description | Status |
|---|---|---|
| `SectionDetailView.swift` | Date bar, summary strip (P/A/L counts), student attendance list | `[x]` |

### Students (`Views/Students/`)
| File | Description | Status |
|---|---|---|
| `StudentsLibraryView.swift` | Searchable global student list | `[x]` |
| `CreateStudentSheet.swift` | Sheet to create a new student | `[x]` |
| `AddStudentToSectionSheet.swift` | Sheet to assign existing student to a section | `[x]` |

### Profile (`Views/Profile/`)
| File | Description | Status |
|---|---|---|
| `ProfileView.swift` | Professor name, email, logout button | `[x]` |

---

## 7. Reusable Components (`Components/`)

| File | Description | Status |
|---|---|---|
| `FloatingActionButton.swift` | Circular `+` FAB button | `[x]` |
| `EmptyStateView.swift` | Placeholder view for empty lists | `[x]` |
| `AuthTextField.swift` | Styled text field for auth forms | `[x]` |
| `AttendanceStatusPicker.swift` | Segmented / menu picker for Present · Absent · Late | `[x]` |

---

## 8. Navigation

| Route | Status |
|---|---|
| `RootView` → `AuthView` (unauthenticated) | `[x]` |
| `RootView` → `MainTabView` (authenticated) | `[x]` |
| Tab 1: `DashboardView` → `ClassDetailView` → `SectionDetailView` | `[x]` |
| Tab 2: `StudentsLibraryView` | `[x]` |
| Tab 3: `ProfileView` | `[x]` |

---

## 9. Firebase & Backend

| Task | Status |
|---|---|
| Firebase Auth — Registration | `[x]` |
| Firebase Auth — Login / Logout | `[x]` |
| Firebase Auth — Session persistence (auth state listener) | `[x]` |
| Firestore — `professors` collection | `[x]` |
| Firestore — `classes` collection | `[x]` |
| Firestore — `sections` collection | `[x]` |
| Firestore — `students` collection | `[x]` |
| Firestore — `attendance_records` collection | `[x]` |
| Firestore — Security rules (professor-scoped access) | `[x]` |
| Firestore — Offline caching enabled | `[x]` |

---

## 10. Deletion Cascade Rules

| Rule | Implemented |
|---|---|
| Delete Class → deletes all Sections → deletes all AttendanceSessions | `[x]` |
| Delete Section → deletes all AttendanceSessions | `[x]` |
| Remove Student from Section → deletes that student's attendance records | `[x]` |
| Remove Student from Section → student remains in global pool | `[x]` |

---

## 11. Extras / Polish

| Task | Status |
|---|---|
| CSV import for students | `[x]` |
| Calendar date picker in `SectionDetailView` | `[x]` |
| Swipe-to-delete on all list views | `[x]` |
| Error handling & user-facing alerts | `[x]` |
| Loading states while Firestore fetches | `[x]` |
