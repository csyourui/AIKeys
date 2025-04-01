import Foundation
import SwiftUI

class APIKeyValidationViewModel: ObservableObject {
    enum ValidationStatus: Equatable {
        case notValidated
        case validating
        case valid(models: [AIModel])
        case invalid(String)
        
        var color: Color {
            switch self {
            case .notValidated:
                return .gray
            case .validating:
                return .yellow
            case .valid:
                return .green
            case .invalid:
                return .red
            }
        }
        
        var icon: String {
            switch self {
            case .notValidated:
                return "circle"
            case .validating:
                return "circle.dashed"
            case .valid:
                return "checkmark.circle.fill"
            case .invalid:
                return "xmark.circle.fill"
            }
        }
        
        var description: String {
            switch self {
            case .notValidated:
                return "未验证"
            case .validating:
                return "验证中..."
            case .valid(let models):
                if models.isEmpty {
                    return "有效"
                } else {
                    return "有效 (可用\(models.count)个模型)"
                }
            case .invalid(let message):
                return "无效: \(message)"
            }
        }
        
        var models: [AIModel] {
            switch self {
            case .valid(let models):
                return models
            default:
                return []
            }
        }
        
        static func == (lhs: ValidationStatus, rhs: ValidationStatus) -> Bool {
            switch (lhs, rhs) {
            case (.notValidated, .notValidated):
                return true
            case (.validating, .validating):
                return true
            case (.valid(let lhsModels), .valid(let rhsModels)):
                return lhsModels == rhsModels
            case (.invalid(let lhsMessage), .invalid(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    @Published var status: ValidationStatus = .notValidated
    
    func validateAPIKey(apiKey: APIKey) {
        guard let baseURL = apiKey.providerInfo?.baseURL, !baseURL.isEmpty else {
            self.status = .invalid("提供商基础URL为空")
            return
        }
        
        self.status = .validating
        
        APIService.validateAPIKey(baseURL: baseURL, apiKey: apiKey.value) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let models):
                    self.status = .valid(models: models)
                case .failure(let error):
                    switch error {
                    case .invalidURL:
                        self.status = .invalid("无效的URL")
                    case .requestFailed(let underlyingError):
                        self.status = .invalid("请求失败: \(underlyingError.localizedDescription)")
                    case .invalidResponse:
                        self.status = .invalid("无效的响应")
                    case .unauthorized:
                        self.status = .invalid("未授权，API密钥无效")
                    case .serverError(let code):
                        self.status = .invalid("服务器错误: \(code)")
                    case .decodingError:
                        self.status = .invalid("解析响应失败")
                    case .unknown:
                        self.status = .invalid("未知错误")
                    }
                }
            }
        }
    }
}
