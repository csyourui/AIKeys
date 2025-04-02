import Foundation

class APIService {
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
            print("❌ Missing default model for provider")
            completion(.failure(.missingDefaultModel))
            return
        }

        // 构建URL
        let chatEndpoint =
            baseURL.hasSuffix("/")
            ? "\(baseURL)chat/completions"
            : "\(baseURL)/chat/completions"

        print("🔍 API Request - URL: \(chatEndpoint)")

        guard let url = URL(string: chatEndpoint) else {
            print("❌ Invalid URL: \(chatEndpoint)")
            completion(.failure(.invalidURL))
            return
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // 创建请求体
        let requestBody = ChatCompletionRequest(model: defaultModel)

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("❌ Error encoding request body: \(error)")
            completion(.failure(.requestFailed(error)))
            return
        }

        // 发送请求
        let task = URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            // 处理网络错误
            if let error = error {
                print("❌ Network error: \(error)")
                completion(.failure(.requestFailed(error)))
                return
            }

            // 检查响应
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                completion(.failure(.invalidResponse))
                return
            }

            // 根据HTTP状态码处理响应
            switch httpResponse.statusCode {
            case 200...299:
                // 成功
                print("✅ API Key is valid")
                completion(.success(()))
            case 401:
                // 未授权（无效的API密钥）
                print("❌ Unauthorized: Invalid API Key")
                completion(.failure(.unauthorized))
            default:
                // 其他服务器错误
                print("❌ Server Error: Status Code \(httpResponse.statusCode)")
                completion(.failure(.serverError(httpResponse.statusCode)))
            }
        }

        task.resume()
    }
}
