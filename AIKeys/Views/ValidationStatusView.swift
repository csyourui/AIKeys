import SwiftUI

struct ValidationStatusView: View {
    let status: APIKeyValidationViewModel.ValidationStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                
                // For invalid status, use a selectable text component
                if case .invalid = status {
                    Text(status.description)
                        .foregroundColor(status.color)
                        .font(.subheadline)
                        .textSelection(.enabled)  // Enable text selection
                } else {
                    Text(status.description)
                        .foregroundColor(status.color)
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ValidationStatusView(status: .notValidated)
        ValidationStatusView(status: .validating)
        ValidationStatusView(status: .valid)
        ValidationStatusView(status: .invalid("API密钥无效"))
    }
    .padding()
}
