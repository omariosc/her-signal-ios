import Foundation
import Security

class SecureStorage {
    private let serviceName = "com.hersignal.app"
    
    enum StorageError: Error {
        case itemNotFound
        case duplicateItem
        case invalidData
        case unexpectedError(OSStatus)
    }
    
    // MARK: - Generic Storage Methods
    
    func store<T: Codable>(_ item: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(item)
        try storeData(data, forKey: key)
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T {
        let data = try retrieveData(forKey: key)
        return try JSONDecoder().decode(type, from: data)
    }
    
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw StorageError.unexpectedError(status)
        }
    }
    
    func exists(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Emergency Contact Storage
    
    func storeEmergencyContacts(_ contacts: [EmergencyContact]) throws {
        try store(contacts, forKey: "emergency_contacts")
    }
    
    func retrieveEmergencyContacts() throws -> [EmergencyContact] {
        return try retrieve([EmergencyContact].self, forKey: "emergency_contacts")
    }
    
    // MARK: - User Preferences Storage
    
    func storeUserPreferences(_ preferences: UserPreferences) throws {
        try store(preferences, forKey: "user_preferences")
    }
    
    func retrieveUserPreferences() throws -> UserPreferences {
        return try retrieve(UserPreferences.self, forKey: "user_preferences")
    }
    
    // MARK: - Emergency Data Deletion
    
    func clearAllData() throws {
        let keys = [
            "emergency_contacts",
            "user_preferences",
            "call_history",
            "location_history"
        ]
        
        for key in keys {
            try delete(forKey: key)
        }
    }
    
    func clearSensitiveData() throws {
        // Clear only the most sensitive data while preserving user preferences
        let sensitiveKeys = [
            "call_history",
            "location_history"
        ]
        
        for key in sensitiveKeys {
            try delete(forKey: key)
        }
    }
    
    // MARK: - Private Methods
    
    private func storeData(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: serviceName,
                kSecAttrAccount as String: key
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            if updateStatus != errSecSuccess {
                throw StorageError.unexpectedError(updateStatus)
            }
        } else if status != errSecSuccess {
            throw StorageError.unexpectedError(status)
        }
    }
    
    private func retrieveData(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            throw StorageError.itemNotFound
        } else if status != errSecSuccess {
            throw StorageError.unexpectedError(status)
        }
        
        guard let data = result as? Data else {
            throw StorageError.invalidData
        }
        
        return data
    }
}

// MARK: - Data Models

struct UserPreferences: Codable {
    var preferredVoice: VoicePersona
    var defaultScenario: CallScenario
    var autoAnswerDelay: TimeInterval
    var enableLocationSharing: Bool
    var enableNotifications: Bool
    var emergencyContactIds: [String]
    
    init() {
        self.preferredVoice = .maya
        self.defaultScenario = .walkingSafety
        self.autoAnswerDelay = 3.0
        self.enableLocationSharing = false
        self.enableNotifications = true
        self.emergencyContactIds = []
    }
}