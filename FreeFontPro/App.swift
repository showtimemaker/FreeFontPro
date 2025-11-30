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
    
    // var sharedModelContainer: ModelContainer = {
    //     let schema = Schema([
    //         FreeFontData.self,
    //     ])
    //     let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    //     do {
    //         return try ModelContainer(for: schema, configurations: [modelConfiguration])
    //     } catch {
    //         fatalError("Could not create ModelContainer: \(error)")
    //     }
    // }()
    
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(colorScheme)
        }
        // .modelContainer(sharedModelContainer)
    }
    
    /// 根据用户设置返回颜色方案
    private var colorScheme: ColorScheme? {
        if useSystemAppearance {
            return nil // 跟随系统
        }
        return isDarkMode ? .dark : .light
    }
}
