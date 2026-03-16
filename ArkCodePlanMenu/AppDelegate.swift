//
//  AppDelegate.swift
//  ArkCodePlanMenu
//
//  Created on 2026/03/16.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuManager: MenuBarManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 初始化
        if let token = TokenStore.shared.token {
            APIClient.shared.setToken(token)
        }
        
        menuManager = MenuBarManager.shared
        menuManager.setup()
        
        // 设置右键菜单
        if let button = menuManager.statusItem?.button {
            button.sendAction(onRightClick: { [weak self] _ in
                guard let self = self else { return }
                let menu = self.menuManager.buildMenu()
                self.menuManager.statusItem?.button?.rightClickMenu = menu
            })
        }
        
        // 首次刷新
        Task { @MainActor in
            if TokenStore.shared.hasToken {
                await menuManager.refresh()
            }
        }
        
        // 设置开机自启动
        setupLoginItem()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup
    }
}

// MARK: - 右键点击支持
extension NSStatusBarButton {
    private static var rightClickAssociation: Void?
    func sendAction(onRightClick closure: @escaping (NSEvent) -> Void) {
        objc_setAssociatedObject(self, &Self.rightClickAssociation, closure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        replaceActionIfNecessary()
    }
    
    var rightClickMenu: NSMenu? {
        get {
            if let closure = objc_getAssociatedObject(self, &Self.rightClickAssociation) as? (NSEvent) -> Void {
                // 菜单通过 closure 设置
                return nil
            }
            return nil
        }
        set {
            if let menu = newValue {
                objc_setAssociatedObject(self, &Self.rightClickAssociation, { _ in
                    if let menu = newValue {
                        NSMenu.popUpContextMenu(menu, with: NSEvent.mouseLocation, for: self)
                    }
                } as (NSEvent) -> Void, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                replaceActionIfNecessary()
            }
        }
    }
    
    private func replaceActionIfNecessary() {
        if let originalTarget = target as AnyObject? {
            let block: @convention(block) (AnyObject) -> Void = { [weak self] _ in
                guard let self = self else { return }
                if let block = objc_getAssociatedObject(self, &Self.rightClickAssociation) as? (NSEvent) -> Void {
                    block(NSEvent.mouseLocation)
                }
            }
            objc_setAssociatedObject(self, UnsafeRawPointer(bitPattern: 1)!, block, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.target = objc_getAssociatedObject(self, UnsafeRawPointer(bitPattern: 1)!) as? AnyObject
            self.action = #selector(block(_:))
        }
    }
    
    @objc private func block(_ sender: AnyObject) {
        if let block = objc_getAssociatedObject(self, UnsafeRawPointer(bitPattern: 1)!) as? (AnyObject) -> Void {
            block(sender)
        }
    }
}

// MARK: - 开机自启动
extension AppDelegate {
    func setupLoginItem() {
        let shouldLaunch = TokenStore.shared.launchAtLogin
        // 注意：这个需要应用签名才能正常工作，开发阶段可以忽略
        // 实际使用中用户可以手动在系统设置中添加
    }
}
