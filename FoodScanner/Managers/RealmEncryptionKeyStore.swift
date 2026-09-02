//
//  RealmEncryptionKeyStore.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
// SECURITY: generates and persists the 64-byte AES-256 key Realm uses to encrypt its file on disk, kept only in the Keychain (kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly), never alongside the .realm file itself.
//

import Foundation

enum RealmEncryptionKeyStore {
    private static let account = "com.foodscanner.realm.encryptionKey"
    private static let keyLength = 64

    // SECURITY: returns the existing key from the Keychain, or generates, stores, and returns a new one.
    static func key() -> Data {
        if let existingKey = readKey() {
            return existingKey
        }

        var newKey = Data(count: keyLength)
        let result = newKey.withUnsafeMutableBytes { buffer -> Int32 in
            guard let baseAddress = buffer.baseAddress else { return errSecParam }
            return SecRandomCopyBytes(kSecRandomDefault, keyLength, baseAddress)
        }
        precondition(result == errSecSuccess, "Failed to generate a secure random Realm encryption key")

        store(newKey)
        return newKey
    }

    private static func readKey() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return data
    }

    private static func store(_ key: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        precondition(status == errSecSuccess, "Failed to store the Realm encryption key in the Keychain")
    }
}
