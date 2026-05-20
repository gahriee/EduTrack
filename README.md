# EduTrack 🎓

**EduTrack** is a robust, iOS-native Student Attendance Manager built entirely with Swift, SwiftUI, and Firebase. It allows professors to seamlessly manage their classes, enroll students, and record daily attendance with ease. 

Designed with an MVVM architecture, EduTrack ensures a clean separation of concerns and features real-time cloud synchronization using Firebase Auth and Firestore.

## 🌟 Features

- **Authentication**: Secure login and registration powered by Firebase Authentication.
- **Class Management**: Create and manage multiple classes, complete with cascading deletions to keep your database clean.
- **Section & Roster Management**: Break classes down into smaller sections and easily assign students to them.
- **Real-time Attendance**: A beautiful, intuitive UI to take attendance (Present, Absent, Late) on any specific date.
- **Global Student Library**: Manage all your students in a single, searchable global pool.
- **Bulk Import**: Quickly enroll students into your global library by uploading a CSV file.
- **Cloud Sync**: All data is instantly synced and persisted via Firebase Firestore, complete with offline support.

## 🛠 Tech Stack

- **Platform**: iOS 15.0+ / macOS 13.0+
- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Backend & Persistence**: Firebase (Auth & Firestore)
- **Dependency Management**: Swift Package Manager (SPM)

## 📁 Project Structure

```text
EduTrack/
├── App/                  # App entry point (AttendanceApp) and Root router
├── Models/               # Data structures (Professor, SchoolClass, Student, etc.)
├── Services/             # DataStore logic handling Firebase CRUD operations
├── Views/                # SwiftUI Views organized by feature
│   ├── Auth/             # Login & Registration flows
│   ├── Classes/          # Class detail & section creation
│   ├── Dashboard/        # Main landing page for classes
│   ├── Profile/          # Professor profile & logout
│   ├── Sections/         # The core attendance tracking screen
│   └── Students/         # Global student library & CSV import
└── Components/           # Reusable UI elements (FAB, custom pickers, empty states)
```

## 🚀 Getting Started

### Prerequisites
1. **Xcode 15+**.
2. **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** — install via Homebrew: `brew install xcodegen`.
3. A **Firebase Project** set up in the [Firebase Console](https://console.firebase.google.com/).

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd EduTrack
   ```

2. **Configure Firebase:**
   - In your Firebase Console, create a new iOS App with the bundle identifier `com.example.EduTrack` (or your chosen bundle ID).
   - Enable **Email/Password** sign-in under the Authentication tab.
   - Create a **Firestore Database** in production mode.
   - Deploy the provided `firestore.rules` to secure your database.
   - Download the `GoogleService-Info.plist` file and place it in the `Sources/EduTrack/` directory, replacing the placeholder file.

3. **Generate the Xcode project:**
   ```bash
   xcodegen generate
   ```
   This reads `project.yml` and creates `EduTrack.xcodeproj`.

4. **Build & Run:**
   - Open `EduTrack.xcodeproj` in Xcode.
   - Wait for SPM to resolve the `firebase-ios-sdk` dependencies.
   - Select your target simulator (e.g., iPhone 15 Pro) and hit **Run** (`Cmd + R`).

## 🛡 Security Rules

EduTrack utilizes strict Firestore Security Rules to ensure data privacy. Professors can only read and write data (classes, sections, attendance records) that belongs directly to their authenticated user ID (`uid`). The rules are provided in the `firestore.rules` file in the root directory.

---
*Built with ❤️ using SwiftUI & Firebase.*
