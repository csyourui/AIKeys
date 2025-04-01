import Foundation
import SwiftUI

// API提供商信息模型
struct APIProvider: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    let name: String
    let homepage: String
    let baseURL: String
    let description: String
    let logoName: String?
    let iconURL: String?
    
    init(id: UUID = UUID(), name: String, homepage: String, baseURL: String, description: String, logoName: String? = nil, iconURL: String? = nil) {
        self.id = id
        self.name = name
        self.homepage = homepage
        self.baseURL = baseURL
        self.description = description
        self.logoName = logoName
        self.iconURL = iconURL
    }
    
    static func == (lhs: APIProvider, rhs: APIProvider) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // 获取图标
    var iconImage: Image? {
        if let logoName = logoName {
            return Image(logoName)
        }
        return nil
    }
    
    // 预定义的常用API提供商
    static let commonProviders: [APIProvider] = [
        APIProvider(
            name: "OpenAI",
            homepage: "https://openai.com",
            baseURL: "https://api.openai.com/v1",
            description: "提供GPT系列模型API访问的人工智能公司",
            logoName: "openai"
        ),
        APIProvider(
            name: "DeepSeek",
            homepage: "https://www.deepseek.com",
            baseURL: "https://api.deepseek.com",
            description: "提供GPT系列模型API访问的人工智能公司",
            logoName: "ProviderIcons"
        )
    ]
    
    // 根据名称查找预定义的提供商
    static func findCommonProvider(byName name: String) -> APIProvider? {
        return commonProviders.first { $0.name.lowercased() == name.lowercased() }
    }
    
    // 创建自定义提供商
    static func createCustomProvider(name: String) -> APIProvider {
        return APIProvider(
            name: name,
            homepage: "",
            baseURL: "",
            description: "自定义API提供商",
            logoName: nil
        )
    }
}
