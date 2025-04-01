import Foundation

// 用于持久化的基础模型，不包含敏感的密钥值
struct StorableAPIKey: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let provider: String
    let providerID: UUID?  // 关联的API提供商ID
    let dateAdded: Date
    
    init(id: UUID = UUID(), name: String, provider: String, providerID: UUID? = nil, dateAdded: Date = Date()) {
        self.id = id
        self.name = name
        self.provider = provider
        self.providerID = providerID
        self.dateAdded = dateAdded
    }
    
    static func == (lhs: StorableAPIKey, rhs: StorableAPIKey) -> Bool {
        return lhs.id == rhs.id
    }
}

// 完整的API密钥模型，包含敏感的密钥值
struct APIKey: Identifiable, Equatable, Codable, Hashable {
    let base: StorableAPIKey
    let value: String
    var providerInfo: APIProvider?
    
    var id: UUID { base.id }
    var name: String { base.name }
    var provider: String { base.provider }
    var providerID: UUID? { base.providerID }
    var dateAdded: Date { base.dateAdded }
    
    init(id: UUID = UUID(), name: String, provider: String, value: String, providerID: UUID? = nil, providerInfo: APIProvider? = nil, dateAdded: Date = Date()) {
        self.base = StorableAPIKey(id: id, name: name, provider: provider, providerID: providerID, dateAdded: dateAdded)
        self.value = value
        self.providerInfo = providerInfo ?? APIProvider.findCommonProvider(byName: provider) ?? APIProvider.createCustomProvider(name: provider)
    }
    
    // 获取不包含敏感值的版本，用于持久化
    func toStorable() -> StorableAPIKey {
        return base
    }
    
    static func == (lhs: APIKey, rhs: APIKey) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 实现Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // 获取提供商主页
    var providerHomepage: String {
        return providerInfo?.homepage ?? ""
    }
    
    // 获取提供商基础URL
    var providerBaseURL: String {
        return providerInfo?.baseURL ?? ""
    }
    
    // 获取提供商描述
    var providerDescription: String {
        return providerInfo?.description ?? "自定义API提供商"
    }
}
