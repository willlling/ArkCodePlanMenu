//
//  TokenStore.swift
//  ArkCodePlanMenu
//
//  Created on 2026/03/16.
//

import Foundation

class TokenStore {
    static let shared = TokenStore()
    
    private let defaults = UserDefaults.standard
    private let tokenKey = "ark.msToken"
    private let refreshIntervalKey = "ark.refreshInterval"
    private let launchAtLoginKey = "ark.launchAtLogin"
    
    private init() {}
    
    var token: String? {
        get {
            return defaults.string(forKey: tokenKey)
        }
        set {
            defaults.set(newValue, forKey: tokenKey)
            APIClient.shared.setToken(newValue ?? "")
        }
    }
    
    var refreshIntervalMinutes: Double {
        get {
            let stored = defaults.double(forKey: refreshIntervalKey)
            return stored > 0 ? stored : 15 // 默认 15 分钟刷新一次
        }
        set {
            defaults.set(newValue, forKey: refreshIntervalKey)
        }
    }
    
    var launchAtLogin: Bool {
        get {
            return defaults.bool(forKey: launchAtLoginKey)
        }
        set {
            defaults.set(newValue, forKey: launchAtLoginKey)
        }
    }
    
    func hasToken -> Bool {
        if let token = token, !token.isEmpty {
            return true
        }
        return false
    }
    
    func clear() {
        token = nil
    }
}
