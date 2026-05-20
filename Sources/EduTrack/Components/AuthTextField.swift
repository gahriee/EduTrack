import SwiftUI

struct AuthTextField: View {
    var title: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if isSecure {
                SecureField("", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                TextField("", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
            }
        }
    }
}
