//
//  Models.swift
//  ArkCodePlanMenu
//
//  Created on 2026/03/16.
//

import Foundation

struct SubscriptionInfo: Codable, Equatable {
    let planName: String
    let totalTokens: Int
    let usedTokens: Int
    let remainingTokens: Int
    
    var usagePercentage: Double {
        guard totalTokens > 0 else { return 0 }
        return Double(usedTokens) / Double(totalTokens)
    }
    
    var remainingPercentage: Double {
        guard totalTokens > 0 else { return 0 }
        return Double(remainingTokens) / Double(totalTokens)
    }
    
    /// 格式化大数字显示（比如 75000 → 75K）
    var formattedRemaining: String {
        if remainingTokens >= 1000 {
            return String(format: "%.1fK", Double(remainingTokens) / 1000)
        }
        return "\(remainingTokens)"
    }
    
    /// 颜色状态 based on 剩余比例
    var statusColor: String {
        switch remainingPercentage {
        case ..<0.1:
            return "danger" // 红色
        case 0.1..<0.2:
            return "warning" // 黄色
        default:
            return "normal" // 绿色
        }
    }
}

struct APIError: Error {
    let message: String
    let statusCode: Int
    
    init(message: String, statusCode: Int = -1) {
        self.message = message
        self.statusCode = statusCode
    }
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
