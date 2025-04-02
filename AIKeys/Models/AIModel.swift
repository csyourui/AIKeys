import Foundation

// 聊天消息结构体
struct ChatMessage: Codable {
    let role: String
    let content: String
}

// 聊天完成请求结构体
struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]

    init(model: String, messages: [ChatMessage] = []) {
        self.model = model
        self.messages =
            messages.isEmpty
            ? [
                ChatMessage(role: "system", content: "You are a helpful assistant."),
                ChatMessage(role: "user", content: "Hello!"),
            ] : messages
    }
}

// 聊天完成响应结构体
struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]

    struct Choice: Codable {
        let index: Int
        let message: ChatMessage
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
}
