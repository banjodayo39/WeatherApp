//
//  SecureLogIn.swift
//  WeatherApp
//
//  Created by Home on 1/19/21.
//

import Foundation


class SecureMgr {
    
    static func deleteKeyChain(query: [String: Any]) -> Bool{
        let result = SecItemDelete(query as CFDictionary)
        
        return result == errSecSuccess
    }
    
    static func deleteUserPassword(username: String, password : String) -> Bool{
        
        let pwData = password.data(using: .utf8)!        
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: username        ]
        
        
        return deleteKeyChain(query: _query)
        
    }
    
    static func updateKeyChain(query: [String: Any],
                              attrs : [String: Any]) -> Bool{
        let result = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
        
        return result == errSecSuccess
    }
    
    static func updateUserPassword(username: String, password : String) -> Bool{
        
        let pwData = password.data(using: .utf8)!        
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: username        ]
        
        let attr : [String : Any] = [
                                       kSecValueData as String: pwData
        ]
        
        
        return updateKeyChain(query: _query, attrs: attr)
        
    }
    static func findInKeyChain(query : [String :Any]) -> String?{
        var item : CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        guard result == errSecSuccess else{ return nil}
        
        let msg = SecCopyErrorMessageString(result, nil)
        print(msg)
        
        guard  let theItem = item as? [String: Any],
               let pwData = theItem[kSecValueData as String] as? Data,
               let password = String(data: pwData, encoding: .utf8),
               let account = theItem[kSecAttrAccount as String] as? String 
        else { return nil}
        
        return password
                
    }
     
    static func retrievePassword(username : String) -> String?{
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: username,
                                       kSecReturnAttributes as String : true,
                                       kSecReturnData as String: true 
        ]
        
        return findInKeyChain(query: _query)
    }
    
    static func addToKeyChain(query: [String : Any]) -> Bool{
        
        let result = SecItemAdd(query as CFDictionary, nil)
        let msg = SecCopyErrorMessageString(result, nil)
        print(msg)
        
        return result == errSecSuccess
    }
    
    static func storeLogin(username: String, password: String) -> Bool{
        
        // Store Username and Passowrd in Keychain
        let pwData = password.data(using: .utf8)!        
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                      kSecAttrAccount as String: username,
                                      kSecValueData as String: pwData
        ]
        
        return addToKeyChain(query: _query)
    }
    
    static func storeInternetData(username: String, password: String, server: String, userType: String) -> Bool{
        
        // Store Username and Passowrd in Keychain
        let pwData = password.data(using: .utf8)!        
        let _query : [String : Any] = [kSecClass as String: kSecClassInternetPassword,
                                       kSecAttrLabel as String: userType,
                                       kSecAttrServer as String: server,
                                       kSecAttrAccount as String: username,
                                       kSecValueData as String: pwData
        ]
        
        return addToKeyChain(query: _query)
    }
    
    static func retrieveData(username : String) -> String?{
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: username,
                                       kSecReturnData as String: true 
        ]
        
        return findInKeyChain(query: _query)
    }
    
    static func findInDataKeyChain(query : [String :Any]) -> String?{
        var item : CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        guard result == errSecSuccess else{ return nil}
        
        let msg = SecCopyErrorMessageString(result, nil)
        print(msg)
        
        if let pwdData = item as? Data{
            let password = String(data: pwdData, encoding: .utf8)
            return password
        }
        
        guard  let theItem = item as? [String: Any],
               let pwData = theItem[kSecValueData as String] as? Data,
               let password = String(data: pwData, encoding: .utf8),
               let account = theItem[kSecAttrAccount as String] as? String 
        else { return nil}
        
        return password
        
    }
    
    static func storeItem(uuid: String, note: String) -> Bool{
        
        // Store Username and Passowrd in Keychain
        let tData = note.data(using: .utf8)!        
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: uuid,
                                       kSecValueData as String: tData,
                                       kSecAttrLabel as String: "note"
        ]
        
        return addToKeyChain(query: _query)
    }
    
    static func fetchItem() -> [Note]?{
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: "note",
                                       kSecReturnAttributes as String : true,
                                       kSecReturnData as String: true,
                                       kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var item : CFTypeRef?
        let result = SecItemCopyMatching(_query as CFDictionary, &item)
        guard result == errSecSuccess else{ return nil}
        
        guard let theItems  =  item as? [Dictionary<String, Any>] else {
            return nil
        }
        
        let items = theItems.compactMap{(dict) -> Note? in
            guard let data = dict[kSecValueData as String] as? Data,
                  let text = String(data: data, encoding: .utf8) else { return nil}
            
            return Note(uuid: dict[kSecAttrAccount as String] as! String, text: text)
        }
     
        return items
    }
    
    static func updateNote(text : String, uuid: String) -> Bool{
        let tData = text.data(using: .utf8)!        
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: uuid,
                                       kSecValueData as String: tData,
                                       kSecAttrLabel as String: "note"
        ]
        
        let attrs : [String : Any] = [
            kSecValueData as String: tData
        ]
        
        
        return updateKeyChain(query: _query, attrs: attrs)   
        
    }
    
    static func removeData(uuid : String) -> Bool{
        let _query : [String : Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: uuid,
                                       kSecAttrLabel as String: "note"
        ]
        
        return deleteKeyChain(query: _query)
    }
}

