import Foundation
import Combine

class APIKeyStore: ObservableObject {
    @Published var apiKeys: [APIKey] = []
    private let userDefaultsKey = "storedAPIKeys"
    
    init() {
        loadAPIKeys()
    }
    
    // 添加API密钥
    func addAPIKey(_ apiKey: APIKey) {
        do {
            // 将API密钥值保存到Keychain
            try KeychainManager.save(key: apiKey.value, account: apiKey.id.uuidString)
            
            // 添加到内存中的apiKeys数组
            apiKeys.append(apiKey)
            
            // 保存元数据到UserDefaults
            saveAPIKeys()
        } catch {
            print("Error saving API key to Keychain: \(error)")
        }
    }
    
    // 获取API密钥
    func getAPIKey(with id: UUID) -> APIKey? {
        guard let apiKey = apiKeys.first(where: { $0.id == id }) else {
            return nil
        }
        
        do {
            // 从Keychain获取实际的密钥值
            let value = try KeychainManager.get(account: id.uuidString)
            return APIKey(
                id: apiKey.id,
                name: apiKey.name,
                provider: apiKey.provider,
                value: value,
                dateAdded: apiKey.dateAdded
            )
        } catch {
            print("Error retrieving API key from Keychain: \(error)")
            return nil
        }
    }
    
    // 删除API密钥
    func deleteAPIKey(_ apiKey: APIKey) {
        do {
            // 从Keychain删除密钥值
            try KeychainManager.delete(account: apiKey.id.uuidString)
            
            // 从内存中删除
            if let index = apiKeys.firstIndex(where: { $0.id == apiKey.id }) {
                apiKeys.remove(at: index)
                
                // 更新UserDefaults
                saveAPIKeys()
            }
        } catch {
            print("Error deleting API key from Keychain: \(error)")
        }
    }
    
    // 获取Keychain项ID
    func getKeychainItemID(for apiKey: APIKey) -> String {
        return KeychainManager.getKeychainItemID(for: apiKey.id.uuidString)
    }
    
    // 保存API密钥元数据到UserDefaults
    private func saveAPIKeys() {
        let storableKeys = apiKeys.map { $0.toStorable() }
        if let encoded = try? JSONEncoder().encode(storableKeys) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // 从UserDefaults加载API密钥元数据
    private func loadAPIKeys() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let storableKeys = try? JSONDecoder().decode([StorableAPIKey].self, from: data) else {
            return
        }
        
        // 将StorableAPIKey转换为APIKey，并从Keychain获取密钥值
        apiKeys = storableKeys.compactMap { storableKey in
            do {
                let value = try KeychainManager.get(account: storableKey.id.uuidString)
                return APIKey(
                    id: storableKey.id,
                    name: storableKey.name,
                    provider: storableKey.provider,
                    value: value,
                    dateAdded: storableKey.dateAdded
                )
            } catch {
                print("Error retrieving API key from Keychain: \(error)")
                return nil
            }
        }
    }
}
