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
            HStack(spacing: 4) {
                Text(status.rawValue)
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(colorForStatus(status).opacity(0.15))
            .foregroundColor(colorForStatus(status))
            .cornerRadius(8)
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
