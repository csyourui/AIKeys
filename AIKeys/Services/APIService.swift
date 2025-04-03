import Combine
import Foundation
import OpenAI
import os

class APIService {
    // 创建一个日志记录器
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.yourui.AIKeys", category: "APIService")

    enum APIError: Error {
        case invalidURL
        case requestFailed(Error)
        case invalidResponse
        case unauthorized
        case serverError(Int)
        case decodingError
        case missingDefaultModel
        case unknown
    }

    // 使用聊天完成API验证API密钥
    static func validateAPIKey(
        baseURL: String,
        apiKey: String,
        defaultModel: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        // 检查默认模型
        if defaultModel.isEmpty {
            logger.error("❌ 缺少默认模型")
            completion(.failure(.missingDefaultModel))
            return
        }

        logger.debug("🔗 使用 API URL: \(baseURL)")

        // 检查 URL 是否有效
        guard let url = URL(string: baseURL) else {
            logger.error("❌ 无效的 URL: \(baseURL)")
            completion(.failure(.invalidURL))
            return
        }

        // 使用 baseURL 的主机部分
        let host: String = url.host ?? ""
        if host.isEmpty {
            logger.error("❌ 无效的主机: \(baseURL)")
            completion(.failure(.invalidURL))
            return
        }
        logger.debug("🌐 使用主机: \(host)")

        let configuration = OpenAI.Configuration(
            token: apiKey,
            host: host,
            port: url.port ?? 443,
            scheme: url.scheme ?? "https",
            basePath: url.path.isEmpty ? "/v1" : url.path,
            timeoutInterval: 60.0,
            parsingOptions: .relaxed
        )

        logger.debug("✅ 配置已创建")
        let openAI = OpenAI(configuration: configuration)
        logger.debug("📡 OpenAI 客户端已创建")

        // 创建请求
        let query = ChatQuery(
            messages: [
                .init(role: .user, content: "你是谁")!
            ],
            model: .init(defaultModel),
            maxTokens: 10
        )

        logger.debug("📤 发送请求到模型: \(defaultModel)")

        // 使用 Combine 处理发布者
        var cancellable: AnyCancellable?
        cancellable =
            openAI.chats(query: query)
            .sink(
                receiveCompletion: { completionStatus in
                    switch completionStatus {
                    case .finished:
                        break  // 将在 receiveValue 中处理
                    case .failure(let error):
                        logger.error("❌ API 请求失败: \(error.localizedDescription)")
                        logger.error("❌ 错误详情: \(String(describing: error))")
                        completion(.failure(.requestFailed(error)))
                    }
                    cancellable?.cancel()
                },
                receiveValue: { chatResult in
                    logger.debug("✅ 收到结果")

                    if let content = chatResult.choices.first?.message.content {
                        logger.info("📝 模型回复: \(content)")
                    }

                    // 处理结果
                    if chatResult.choices.isEmpty {
                        logger.error("❌ API 没有返回选项")
                        completion(.failure(.invalidResponse))
                        return
                    }

                    // 处理成功
                    logger.info("✅ API 密钥验证成功")
                    completion(.success(()))
                })
    }
}
