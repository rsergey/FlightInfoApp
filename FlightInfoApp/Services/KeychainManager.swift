//
//  KeychainManager.swift
//  FlightInfoApp
//
//  Created by Sergey on 18.12.2021.
//

import Foundation
import Security

class KeychainManager {
    // MARK: - Static Properties
    static let shared = KeychainManager()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func save(data: String, service: String, account: String) {
        let value: Data = data.data(using: .utf8) ?? Data()
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: value as AnyObject
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            print("Save to keychain failed")
            return
        }
        print("Save to keychain success")
    }
    
    func update(data: String, service: String, account: String) {
        let value: Data = data.data(using: .utf8) ?? Data()
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword]
        let attributes: [String: AnyObject] = [
            kSecValueData as String: value as AnyObject
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status != errSecItemNotFound else {
            print("Item not found")
            return
        }
        
        guard status == errSecSuccess else {
            print("Keychain item update failed")
            return
        }
        print("Keychain item update success")
    }
    
    func read(service: String, account: String) -> String? {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]
        
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        
        guard status != errSecItemNotFound else {
            print("Item not found")
            return nil
        }
        
        guard status == errSecSuccess else {
            print("Keychain item read failed")
            return nil
        }
        
        guard let item = itemCopy as? String else {
            return nil
        }
        
        return item
    }
    
    func delete(service: String, account: String) {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
        ]
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            print("Delete from keychain failed")
            return
        }
        print("Delete from keychain success")
    }
    
}
