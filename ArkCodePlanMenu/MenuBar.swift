//
//  MenuBar.swift
//  ArkCodePlanMenu
//
//  Created on 2026/03/16.
//

import AppKit
import SwiftUI

class MenuBarManager: ObservableObject {
    static let shared = MenuBarManager()
    
    private var statusItem: NSStatusItem!
    private var refreshTimer: Timer?
    
    @Published var subscriptionInfo: SubscriptionInfo?
    @Published var isLoading: Bool = false
    @Published var lastError: String?
    @Published var showPopover: Bool = false
    
    private init() {}
    
    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateMenuBarDisplay()
        setupPopover()
        startTimer()
    }
    
    func setupPopover() {
        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    @objc func togglePopover() {
        if showPopover {
            hidePopover()
        } else {
            showPopover = true
            Task {
                await refresh()
            }
        }
    }
    
    func showPopover(from button: NSStatusBarButton) {
        let popover = NSPopover()
        let contentView = PopoverContentView()
            .environmentObject(self)
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient
        popover.show(relativeTo: button.bounds, of: button)
    }
    
    func hidePopover() {
        showPopover = false
        // 关闭所有 popover
        NSApp.windows.forEach { window in
            if window.className == "NSPopoverWindow" {
                window.close()
            }
        }
    }
    
    func updateMenuBarDisplay() {
        guard let button = statusItem.button else { return }
        
        if isLoading {
            button.title = "Ark: ..."
            return
        }
        
        guard let info = subscriptionInfo else {
            button.title = "Ark: ?"
            return
        }
        
        button.title = "Ark: \(info.formattedRemaining)"
        
        // 根据剩余比例改变文字颜色
        switch info.statusColor {
        case "danger":
            button.contentTintColor = .red
        case "warning":
            button.contentTintColor = .orange
        default:
            button.contentTintColor = nil // 使用系统默认颜色
        }
    }
    
    @MainActor
    func refresh() async {
        isLoading = true
        lastError = nil
        updateMenuBarDisplay()
        
        do {
            if let token = TokenStore.shared.token {
                APIClient.shared.setToken(token)
            }
            let info = try await APIClient.shared.getSubscription()
            subscriptionInfo = info
            lastError = nil
        } catch {
            lastError = error.localizedDescription
            subscriptionInfo = nil
        }
        
        isLoading = false
        updateMenuBarDisplay()
    }
    
    func startTimer() {
        refreshTimer?.invalidate()
        let interval = TokenStore.shared.refreshIntervalMinutes * 60
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                await self.refresh()
            }
        }
    }
    
    func restartTimer() {
        startTimer()
    }
    
    func stopTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}

// MARK: - 右键菜单
extension MenuBarManager {
    func buildMenu() -> NSMenu {
        let menu = NSMenu()
        
        let refreshItem = NSMenuItem(title: "刷新", action: #selector(refreshManually), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "设置", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    @objc func refreshManually() {
        Task { @MainActor in
            await refresh()
        }
    }
    
    @objc func showSettings() {
        // 打开设置窗口
        if let settingsVC = NSHostingController(rootView: SettingsView()) {
            let window = NSWindow(contentViewController: settingsVC)
            window.makeKeyAndOrderFront(nil)
            window.center()
            window.setContentSize(NSSize(width: 400, height: 350))
            window.level = .floating
        }
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}
