import SwiftUI

struct AttendanceStatusPicker: View {
    @Binding var status: AttendanceStatus
    var onChange: (AttendanceStatus) -> Void
    
    var body: some View {
        Menu {
            ForEach(AttendanceStatus.allCases, id: \.self) { s in
                Button(action: {
                    status = s
                    onChange(s)
                }) {
                    Text(s.rawValue)
                    if s == status {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(status.rawValue.uppercased())
                    .font(.system(.caption, design: .rounded).weight(.bold))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(colorForStatus(status).opacity(0.15))
            .foregroundColor(colorForStatus(status))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(colorForStatus(status).opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func colorForStatus(_ status: AttendanceStatus) -> Color {
        switch status {
        case .pending: return .gray
        case .present: return .green
        case .absent: return .red
        case .late: return .orange
        }
    }
}
