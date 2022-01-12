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
    func saveData(data: String, service: String, account: String) -> Bool {
        let updateStatus = update(data: data, service: service, account: account)
        switch updateStatus {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            if save(data: data, service: service, account: account) == errSecSuccess {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    func readData(service: String, account: String) -> String? {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]
        
        var itemCopy: AnyObject?
        let readStatus = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        
        if readStatus == errSecSuccess {
            guard let keyData = itemCopy as? Data else {
                return nil
            }
            guard let keyString = String(data: keyData, encoding: .utf8) else {
                return nil
            }
            return keyString
        } else {
            return nil
        }
    }
    
    func deleteData(service: String, account: String) -> Bool {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
        ]
        
        if SecItemDelete(query as CFDictionary) == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Private Methods
    private func save(data: String, service: String, account: String) -> OSStatus {
        let value: Data = data.data(using: .utf8) ?? Data()
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: value as AnyObject
        ]
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    private func update(data: String, service: String, account: String) -> OSStatus {
        let value: Data = data.data(using: .utf8) ?? Data()
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword]
        let attributes: [String: AnyObject] = [
            kSecValueData as String: value as AnyObject
        ]
        
        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }
}
