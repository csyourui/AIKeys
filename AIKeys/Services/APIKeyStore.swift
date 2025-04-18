import Combine
import Foundation

class APIKeyStore: ObservableObject {
    @Published var apiKeys: [APIKey] = []
    @Published var lastUpdateTimeStamp: TimeInterval = Date().timeIntervalSince1970

    private let userDefaultsKey = "storedAPIKeys"

    init() {
        loadAPIKeys()
    }

    // 添加API密钥
    func addAPIKey(_ apiKey: APIKey) {
        do {
            // 将API密钥值保存到Keychain
            try APIKeychainManager.save(
                key: apiKey.value,
                account: apiKey.id.uuidString
            )

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
            let value = try APIKeychainManager.get(account: id.uuidString)
            return APIKey(
                id: apiKey.id,
                name: apiKey.baseKey.name,
                provider: apiKey.baseKey.provider,
                value: value,
                providerID: apiKey.baseKey.providerID,
                providerInfo: apiKey.providerInfo,
                dateAdded: apiKey.baseKey.dateAdded,
                isValidated: apiKey.baseKey.isValidated
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
            try APIKeychainManager.delete(account: apiKey.id.uuidString)

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

    // 更新API密钥的验证状态
    func updateAPIKeyValidation(id: UUID, isValidated: Bool) {
        if let index = apiKeys.firstIndex(where: { $0.id == id }) {
            var updatedKey = apiKeys[index]
            updatedKey.updateValidationStatus(
                isValidated: isValidated
            )
            apiKeys[index] = updatedKey

            // 保存更新后的元数据
            saveAPIKeys()
        }
    }

    // 更新API密钥
    func updateAPIKey(id: UUID, name: String, provider: String, value: String, providerID: UUID?) {
        if let index = apiKeys.firstIndex(where: { $0.id == id }) {
            let oldKey = apiKeys[index]
            let isValidated = oldKey.baseKey.isValidated
            let dateAdded = oldKey.baseKey.dateAdded

            do {
                // 更新Keychain中的密钥值
                try APIKeychainManager.update(
                    key: value,
                    account: id.uuidString
                )

                // 创建更新后的密钥对象
                let updatedKey = APIKey(
                    id: id,
                    name: name,
                    provider: provider,
                    value: value,
                    providerID: providerID,
                    dateAdded: dateAdded,
                    isValidated: isValidated
                )

                // 更新内存中的对象
                apiKeys[index] = updatedKey

                // 保存更新后的元数据
                saveAPIKeys()
            } catch {
                print("Error updating API key in Keychain: \(error)")
            }
        }
    }

    // 获取Keychain项ID
    func getKeychainItemID(for apiKey: APIKey) -> String {
        return APIKeychainManager.getKeychainItemID(for: apiKey.id.uuidString)
    }

    // 保存API密钥元数据到UserDefaults
    private func saveAPIKeys() {
        lastUpdateTimeStamp = Date().timeIntervalSince1970
        let storableKeys = apiKeys.map { $0.toStorable() }
        if let encoded = try? JSONEncoder().encode(storableKeys) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    // 从UserDefaults加载API密钥元数据
    private func loadAPIKeys() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let storableKeys = try? JSONDecoder().decode(
                [StorableAPIKey].self,
                from: data
            )
        else {
            return
        }

        // 将StorableAPIKey转换为APIKey，并从Keychain获取密钥值
        apiKeys = storableKeys.compactMap { storableKey in
            do {
                let value = try APIKeychainManager.get(
                    account: storableKey.id.uuidString
                )

                return APIKey(
                    id: storableKey.id,
                    name: storableKey.name,
                    provider: storableKey.provider,
                    value: value,
                    providerID: storableKey.providerID,
                    dateAdded: storableKey.dateAdded,
                    isValidated: storableKey.isValidated
                )
            } catch {
                print("Error retrieving API key from Keychain: \(error)")
                return nil
            }
        }
    }
}
