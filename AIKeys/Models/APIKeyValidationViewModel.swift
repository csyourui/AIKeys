import Foundation
import SwiftUI

class APIKeyValidationViewModel: ObservableObject {
    enum ValidationStatus: Equatable {
        case notValidated
        case validating
        case valid
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
            case .valid:
                return "有效"
            case .invalid(let message):
                return "无效: \(message)"
            }
        }

        static func == (lhs: ValidationStatus, rhs: ValidationStatus) -> Bool {
            switch (lhs, rhs) {
            case (.notValidated, .notValidated):
                return true
            case (.validating, .validating):
                return true
            case (.valid, .valid):
                return true
            case (.invalid(let lhsMessage), .invalid(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }

    @Published var status: ValidationStatus = .notValidated
    private var apiKeyStore: APIKeyStore?

    init(apiKeyStore: APIKeyStore? = nil) {
        self.apiKeyStore = apiKeyStore
    }

    // 初始化时检查API密钥的验证状态
    func checkSavedValidation(apiKey: APIKey) {
        if apiKey.baseKey.isValidated {
            self.status = .valid
        } else {
            self.status = .notValidated
        }
    }

    func validateAPIKey(apiKey: APIKey) {
        guard let providerInfo = apiKey.providerInfo,
            !providerInfo.baseURL.isEmpty
        else {
            self.status = .invalid("提供商基础URL为空")
            apiKeyStore?.updateAPIKeyValidation(
                id: apiKey.id,
                isValidated: false
            )
            return
        }

        // 获取默认模型和基础URL
        let defaultModel = providerInfo.defaultModel
        let baseURL = providerInfo.baseURL

        self.status = .validating

        APIService.validateAPIKey(
            baseURL: baseURL,
            apiKey: apiKey.value,
            defaultModel: defaultModel
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(_):
                    self.status = .valid
                    // 保存验证结果
                    self.apiKeyStore?.updateAPIKeyValidation(
                        id: apiKey.id,
                        isValidated: true
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
                    case .missingDefaultModel:
                        errorMessage = "未设置默认模型"
                    case .unknown:
                        errorMessage = "未知错误"
                    }
                    self.status = .invalid(errorMessage)
                    // 保存验证失败结果
                    self.apiKeyStore?.updateAPIKeyValidation(
                        id: apiKey.id,
                        isValidated: false
                    )
                }
            }
        }
    }
}
