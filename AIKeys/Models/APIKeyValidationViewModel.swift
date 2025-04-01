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
    private let apiKeyStore = APIKeyStore()

    // 初始化时检查API密钥的验证状态
    func checkSavedValidation(apiKey: APIKey) {
        if apiKey.isValidated && !apiKey.availableModels.isEmpty {
            self.status = .valid(models: apiKey.availableModels)
        } else {
            self.status = .notValidated
        }
    }

    func validateAPIKey(apiKey: APIKey) {
        guard let baseURL = apiKey.providerInfo?.baseURL, !baseURL.isEmpty
        else {
            self.status = .invalid("提供商基础URL为空")
            apiKeyStore.updateAPIKeyValidation(
                id: apiKey.id,
                isValidated: false,
                models: []
            )
            return
        }

        self.status = .validating

        APIService.validateAPIKey(baseURL: baseURL, apiKey: apiKey.value) {
            [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let models):
                    self.status = .valid(models: models)
                    // 保存验证结果
                    self.apiKeyStore.updateAPIKeyValidation(
                        id: apiKey.id,
                        isValidated: true,
                        models: models
                    )

                case .failure(let error):
                    var errorMessage = ""
                    switch error {
                    case .invalidURL:
                        errorMessage = "无效的URL"
                    case .requestFailed(let underlyingError):
                        errorMessage =
                            "请求失败: \(underlyingError.localizedDescription)"
                    case .invalidResponse:
                        errorMessage = "无效的响应"
                    case .unauthorized:
                        errorMessage = "未授权，API密钥无效"
                    case .serverError(let code):
                        errorMessage = "服务器错误: \(code)"
                    case .decodingError:
                        errorMessage = "解析响应失败"
                    case .unknown:
                        errorMessage = "未知错误"
                    }
                    self.status = .invalid(errorMessage)
                    // 保存验证失败结果
                    self.apiKeyStore.updateAPIKeyValidation(
                        id: apiKey.id,
                        isValidated: false,
                        models: []
                    )
                }
            }
        }
    }
}
