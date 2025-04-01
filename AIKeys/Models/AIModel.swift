import Foundation

struct AIModel: Identifiable, Codable, Equatable {
    let id: String
    let object: String
    let ownedBy: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case ownedBy = "owned_by"
    }
    
    static func == (lhs: AIModel, rhs: AIModel) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ModelListResponse: Codable {
    let object: String
    let data: [AIModel]
}
