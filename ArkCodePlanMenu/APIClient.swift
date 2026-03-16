//
//  APIClient.swift
//  ArkCodePlanMenu
//
//  Created on 2026/03/16.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let url = URL(string: "https://console.volcengine.com/api/top/ark/cn-beijing/2024-01-01/GetCodingPlanUsage")!
    private var msToken: String?
    
    private init() {}
    
    func setToken(_ token: String) {
        self.msToken = token
    }
    
    func getSubscription() async throws -> SubscriptionInfo {
        guard let msToken = msToken, !msToken.isEmpty else {
            throw APIError(message: "Token 未设置", statusCode: -1)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // 设置 Cookie 认证
        request.addValue("msToken=\(msToken)", forHTTPHeaderField: "Cookie")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError(message: "Invalid response", statusCode: -1)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError(message: "API 返回错误", statusCode: httpResponse.statusCode)
        }
        
        // 火山方舟 API 返回格式:
        // {
        //   "data": {
        //     "planName": "Pro Plan",
        //     "total": 1000000,
        //     "used": 150000,
        //     "remaining": 850000
        //   }
        // }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let data = json?["data"] as? [String: Any]
            
            guard let name = data?["planName"] as? String,
                  let total = data?["total"] as? Int,
                  let used = data?["used"] as? Int,
                  let remaining = data?["remaining"] as? Int else {
                throw APIError(message: "无法解析 API 返回数据，请检查 Token 是否正确", statusCode: httpResponse.statusCode)
            }
            
            return SubscriptionInfo(
                planName: name,
                totalTokens: total,
                usedTokens: used,
                remainingTokens: remaining
            )
        } catch {
            throw APIError(message: "解析 JSON 失败: \(error.localizedDescription)", statusCode: httpResponse.statusCode)
        }
    }
}
