import SwiftUI

struct SectionDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    let section: ClassSection
    
    @State private var selectedDate = Date()
    @State private var showingAddStudent = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Header Section (Date Picker + Summary)
                VStack(spacing: 16) {
                    // Date Picker Header
                    HStack {
                        Button(action: { withAnimation(.easeInOut) { changeDate(by: -1) } }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                        
                        Button(action: { withAnimation(.easeInOut) { changeDate(by: 1) } }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Summary Strip
                    let records = currentRecords()
                    let sectionStudents = dataStore.students.filter { currentSection.safeStudentIds.contains($0.id ?? "") }
                    
                    let presentCount = records.filter { $0.status == .present }.count
                    let absentCount = records.filter { $0.status == .absent }.count
                    let lateCount = records.filter { $0.status == .late }.count
                    let pendingCount = records.filter { $0.status == .pending }.count + (sectionStudents.count - records.count) // default pending
                    
                    HStack(spacing: 12) {
                        SummaryItem(title: "Present", count: presentCount, color: .green)
                        SummaryItem(title: "Absent", count: absentCount, color: .red)
                        SummaryItem(title: "Late", count: lateCount, color: .orange)
                        SummaryItem(title: "Pending", count: pendingCount, color: .gray)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 4)
                .zIndex(1)
                
                // Student List
                let sectionStudents = dataStore.students.filter { currentSection.safeStudentIds.contains($0.id ?? "") }
                
                if sectionStudents.isEmpty {
                    Spacer()
                    EmptyStateView(
                        iconName: "person.crop.circle.badge.plus",
                        title: "No Students",
                        message: "Add students to this section to take attendance."
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(sectionStudents.sorted(by: { $0.lastName < $1.lastName })) { student in
                                HStack(spacing: 16) {
                                    // Avatar
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 46))
                                        .foregroundColor(.accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(student.firstName) \(student.lastName)")
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text(student.safeStudentNumber)
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    let status = statusFor(studentId: student.id ?? "")
                                    AttendanceStatusPicker(status: .init(get: { status }, set: { newStatus in
                                        if let sectionId = currentSection.id, let studentId = student.id {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                dataStore.updateRecord(sectionId: sectionId, date: selectedDate, studentId: studentId, status: newStatus)
                                            }
                                            showToastMessage("Status updated to \(newStatus.rawValue)")
                                        }
                                    })) { _ in }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let studentId = student.id, let sectionId = currentSection.id {
                                            withAnimation {
                                                dataStore.removeStudentFromSection(studentId: studentId, sectionId: sectionId)
                                            }
                                        }
                                    } label: {
                                        Label("Remove from Section", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(white: 0.96).edgesIgnoringSafeArea(.bottom))
            
            // Toast Overlay
            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(20)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(2)
                }
            }
        }
        .navigationTitle(currentSection.name)
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
            AddStudentToSectionSheet(section: currentSection)
        }
    }
    
    private func showToastMessage(_ message: String) {
        withAnimation {
            toastMessage = message
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
    
    private var currentSection: ClassSection {
        dataStore.sections.first(where: { $0.id == section.id }) ?? section
    }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func currentRecords() -> [AttendanceRecord] {
        let calendar = Calendar.current
        return dataStore.attendanceRecords.filter {
            $0.sectionId == currentSection.id &&
            calendar.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    private func statusFor(studentId: String) -> AttendanceStatus {
        let records = currentRecords()
        if let record = records.first(where: { $0.studentId == studentId }) {
            return record.status
        }
        return .pending
    }
}

struct SummaryItem: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundColor(color.opacity(0.85))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.12))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}
