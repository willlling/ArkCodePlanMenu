//
//  PopoverContentView.swift
//  ArkCodePlanMenu
//
//  Created on 2026/03/16.
//

import SwiftUI
import Combine

struct PopoverContentView: View {
    @EnvironmentObject var menuManager: MenuBarManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🚀 火山方舟 Code Plan")
                .font(.headline)
                .padding(.bottom, 4)
            
            if menuManager.isLoading {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("加载中...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else if let error = menuManager.lastError {
                Text("❌ 错误: \(error)")
                    .foregroundColor(.red)
                    .font(.caption)
            } else if let info = menuManager.subscriptionInfo {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("📋 套餐")
                        Spacer()
                        Text(info.planName)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("💎 总额")
                        Spacer()
                        Text("\(info.totalTokens) tokens")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("✅ 已用")
                        Spacer()
                        Text("\(info.usedTokens) tokens")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("🎯 剩余")
                        Spacer()
                        Text("\(info.remainingTokens) tokens")
                            .fontWeight(.medium)
                            .foregroundColor(colorForStatus(info.statusColor))
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("已使用 \(String(format: "%.1f%%", info.usagePercentage * 100))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        ProgressView(value: info.usagePercentage)
                            .tint(colorForStatus(info.statusColor))
                            .frame(height: 6)
                    }
                }
                .padding(.vertical, 8)
            } else {
                Text("暂无数据，请检查 Token 设置")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack(spacing: 16) {
                Button {
                    Task {
                        await menuManager.refresh()
                    }
                } label: {
                    Label("刷新", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button {
                    menuManager.showSettings()
                } label: {
                    Label("设置", systemImage: "gear")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    func colorForStatus(_ status: String) -> Color {
        switch status {
        case "danger":
            return .red
        case "warning":
            return .orange
        default:
            return .green
        }
    }
}

struct PopoverContentView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverContentView()
            .environmentObject(MenuBarManager.shared)
    }
}
