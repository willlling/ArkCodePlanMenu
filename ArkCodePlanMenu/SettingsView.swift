//
//  SettingsView.swift
//  ArkCodePlanMenu
//
//  Created on 2026/03/16.
//

import SwiftUI

struct SettingsView: View {
    @State private var token: String = ""
    @State private var refreshInterval: Double = 15
    @State private var launchAtLogin: Bool = false
    @State private var isSaving: Bool = false
    @State private var saveMessage: String?
    @State private var saveMessageColor: Color = .green
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("⚙️ 设置")
                .font(.title)
                .bold()
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("msToken")
                    .font(.headline)
                Text("从火山方舟控制台复制你的 msToken")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入 msToken", text: $token)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("自动刷新间隔: \(Int(refreshInterval)) 分钟")
                    .font(.headline)
                Slider(value: $refreshInterval, in: 1...60, step: 1)
                    .tint(.blue)
                HStack {
                    Text("1 分钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("60 分钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle("开机自动启动", isOn: $launchAtLogin)
                    .font(.headline)
            }
            
            if let message = saveMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(saveMessageColor)
            }
            
            Spacer()
            
            Divider()
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("保存") {
                    saveSettings()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaving)
            }
        }
        .padding()
        .frame(width: 400, height: 350)
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    func loadCurrentSettings() {
        token = TokenStore.shared.token ?? ""
        refreshInterval = TokenStore.shared.refreshIntervalMinutes
        launchAtLogin = TokenStore.shared.launchAtLogin
    }
    
    func saveSettings() {
        isSaving = true
        saveMessage = nil
        
        // 保存设置
        TokenStore.shared.token = token.trimmingCharacters(in: .whitespacesAndNewlines)
        TokenStore.shared.refreshIntervalMinutes = refreshInterval
        TokenStore.shared.launchAtLogin = launchAtLogin
        
        // 重启定时器
        MenuBarManager.shared.restartTimer()
        
        // 立即刷新
        Task { @MainActor in
            await MenuBarManager.shared.refresh()
            isSaving = false
            saveMessage = "✅ 设置已保存"
            saveMessageColor = .green
            
            // 稍候关闭窗口
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
