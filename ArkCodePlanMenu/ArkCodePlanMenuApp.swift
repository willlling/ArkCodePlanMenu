//
//  ArkCodePlanMenuApp.swift
//  ArkCodePlanMenu
//
//  Created on 2026/03/16.
//

import SwiftUI
import Cocoa

@main
struct ArkCodePlanMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        // 菜单栏应用不需要主窗口
        Settings {
            SettingsView()
        }
    }
}
