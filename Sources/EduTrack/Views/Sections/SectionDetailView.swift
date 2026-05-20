import SwiftUI

struct SectionDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    let section: Section
    
    @State private var selectedDate = Date()
    @State private var showingAddStudent = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Date Picker Header
            HStack {
                Button(action: { changeDate(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .padding()
                }
                
                Spacer()
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(CompactDatePickerStyle())
                
                Spacer()
                
                Button(action: { changeDate(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            }
            .background(Color(white: 0.98))
            
            // Summary Strip
            let records = currentRecords()
            let sectionStudents = dataStore.students.filter { section.studentIds.contains($0.id ?? "") }
            
            let presentCount = records.filter { $0.status == .present }.count + (sectionStudents.count - records.count) // default present
            let absentCount = records.filter { $0.status == .absent }.count
            let lateCount = records.filter { $0.status == .late }.count
            
            HStack(spacing: 20) {
                SummaryItem(title: "Present", count: presentCount, color: .green)
                SummaryItem(title: "Absent", count: absentCount, color: .red)
                SummaryItem(title: "Late", count: lateCount, color: .orange)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(white: 1.0))
            .shadow(color: .black.opacity(0.05), radius: 3, y: 3)
            .zIndex(1)
            
            // Student List
            if sectionStudents.isEmpty {
                Spacer()
                EmptyStateView(
                    iconName: "person.crop.circle.badge.plus",
                    title: "No Students",
                    message: "Add students to this section to take attendance."
                )
                Spacer()
            } else {
                List {
                    ForEach(sectionStudents.sorted(by: { $0.lastName < $1.lastName })) { student in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(student.firstName) \(student.lastName)")
                                    .font(.headline)
                                Text(student.studentNumber)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            let status = statusFor(studentId: student.id ?? "")
                            AttendanceStatusPicker(status: .init(get: { status }, set: { newStatus in
                                if let sectionId = section.id, let studentId = student.id {
                                    dataStore.updateRecord(sectionId: sectionId, date: selectedDate, studentId: studentId, status: newStatus)
                                }
                            })) { _ in }
                        }
                    }
                    .onDelete { indexSet in
                        let sortedStudents = sectionStudents.sorted(by: { $0.lastName < $1.lastName })
                        for index in indexSet {
                            if let studentId = sortedStudents[index].id, let sectionId = section.id {
                                dataStore.removeStudentFromSection(studentId: studentId, sectionId: sectionId)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(section.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showingAddStudent = true }) {
                        Label("Add Student", systemImage: "person.badge.plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddStudent) {
            AddStudentToSectionSheet(section: section)
        }
    }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func currentRecords() -> [AttendanceRecord] {
        let calendar = Calendar.current
        return dataStore.attendanceRecords.filter {
            $0.sectionId == section.id &&
            calendar.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    private func statusFor(studentId: String) -> AttendanceStatus {
        let records = currentRecords()
        if let record = records.first(where: { $0.studentId == studentId }) {
            return record.status
        }
        // Default to present if unrecorded
        return .present
    }
}

struct SummaryItem: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2.weight(.bold))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
