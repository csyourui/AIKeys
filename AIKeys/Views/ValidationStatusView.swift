import SwiftUI

struct ValidationStatusView: View {
    let status: APIKeyValidationViewModel.ValidationStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                
                Text(status.description)
                    .foregroundColor(status.color)
                    .font(.subheadline)
            }
            
            // 显示模型列表
            if !status.models.isEmpty {
                Text("可用模型:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.top, 4)
                
                ForEach(status.models) { model in
                    HStack(spacing: 6) {
                        Image(systemName: "cube.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text(model.id)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text(model.ownedBy)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ValidationStatusView(status: .notValidated)
        ValidationStatusView(status: .validating)
        ValidationStatusView(status: .valid(models: []))
        ValidationStatusView(status: .valid(models: [
            AIModel(id: "deepseek-chat", object: "model", ownedBy: "deepseek"),
            AIModel(id: "deepseek-reasoner", object: "model", ownedBy: "deepseek")
        ]))
        ValidationStatusView(status: .invalid("API密钥无效"))
    }
    .padding()
}
