//
//  FreeFont_ProApp.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/21.
//

import SwiftUI
import SwiftData
import SDWebImage
import SDWebImageSVGCoder

@main
struct FreeFont_Pro_App: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("useSystemAppearance") private var useSystemAppearance: Bool = true
    
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(colorScheme)
        }
    }
    
    /// 根据用户设置返回颜色方案
    private var colorScheme: ColorScheme? {
        if useSystemAppearance {
            return nil // 跟随系统
        }
        return isDarkMode ? .dark : .light
    }
}
