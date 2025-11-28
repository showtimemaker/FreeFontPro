//
//  FontServiceTests.swift
//  FreeFontProTests
//
//  Created by chiu on 2025/11/28.
//

import Testing
import Foundation
@testable import FreeFontPro

struct FontServiceTests {
    
    @Test func fetchVersionReturnsNonEmptyString() async throws {
        let service = FontService.shared
        let version = try await service.fetchVersion()
        #expect(!version.isEmpty)
    }
    
    @Test func fetchFontsReturnsData() async throws {
        let service = FontService.shared
        let fonts = try await service.fetchFonts()
        #expect(!fonts.isEmpty)
        
        if let firstFont = fonts.first {
            #expect(!firstFont.id.isEmpty)
            // 验证 name 字典不为空
            #expect(!firstFont.name.isEmpty)
            // 验证至少有一个下载链接
            if let firstVariant = firstFont.postscriptNames.first {
                #expect(!firstVariant.downloadUrls.isEmpty)
            }
        }
    }
}
