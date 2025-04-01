import Foundation

class APIService {
    enum APIError: Error {
        case invalidURL
        case requestFailed(Error)
        case invalidResponse
        case unauthorized
        case serverError(Int)
        case decodingError(Error)
        case unknown
    }

    // 验证API密钥
    static func validateAPIKey(
        baseURL: String,
        apiKey: String,
        completion: @escaping (Result<[AIModel], APIError>) -> Void
    ) {
        // 构建URL
        let modelsEndpoint =
            baseURL.hasSuffix("/") ? "\(baseURL)models" : "\(baseURL)/models"

        print("🔍 API Request - URL: \(modelsEndpoint)")

        guard let url = URL(string: modelsEndpoint) else {
            print("❌ Invalid URL: \(modelsEndpoint)")
            completion(.failure(.invalidURL))
            return
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(
            "Bearer \(apiKey)",
            forHTTPHeaderField: "Authorization"
        )

        // 打印请求信息
        print("📤 Request Method: \(request.httpMethod ?? "Unknown")")
        print(
            "📤 Request Headers: \(request.allHTTPHeaderFields?.description ?? "None")"
        )

        // 执行请求
        let task = URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            // 处理网络错误
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }

            // 检查HTTP响应
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid Response: Not an HTTP response")
                completion(.failure(.invalidResponse))
                return
            }

            // 打印响应信息
            print("📥 Response Status Code: \(httpResponse.statusCode)")
            print("📥 Response Headers: \(httpResponse.allHeaderFields)")

            if let data = data,
                let responseString = String(data: data, encoding: .utf8)
            {
                print("📥 Response Body: \(responseString)")
            }

            // 根据状态码判断结果
            switch httpResponse.statusCode {
            case 200...299:
                // 成功响应
                print("✅ API Key Validation Successful")

                // 解析模型列表
                if let data = data {
                    do {
                        let modelResponse = try JSONDecoder().decode(
                            ModelListResponse.self,
                            from: data
                        )
                        print(
                            "📋 Available Models: \(modelResponse.data.map { $0.id }.joined(separator: ", "))"
                        )
                        completion(.success(modelResponse.data))
                    } catch {
                        print(
                            "❌ JSON Decoding Error: \(error.localizedDescription)"
                        )
                        completion(.failure(.decodingError(error)))
                    }
                } else {
                    completion(.success([]))
                }

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
