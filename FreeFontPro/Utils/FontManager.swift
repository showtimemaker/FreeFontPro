//
//  FontInstallService.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/28.
//

import Foundation
import CoreText

class FontManager {
    static let shared = FontManager()
    
    private init() {}
    
    /// 安装字体
    /// - Parameter url: 字体文件的本地 URL
    func installFont(from url: URL) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let fontURLs = [url] as CFArray
            
            // 使用 .user 作用域安装字体，这通常会触发系统弹窗请求用户许可
            CTFontManagerRegisterFontURLs(fontURLs, .user, true) { (errors, done) -> Bool in
                if done {
                    if let errors = errors as? [CFError], let error = errors.first {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
                return true
            }
        }
    }
    
    /// 检查字体是否已注册
    /// - Parameter postscriptName: 字体的 PostScript 名称
    func isFontRegistered(postscriptName: String) -> Bool {
        let font = CTFontCreateWithName(postscriptName as CFString, 12.0, nil)
        // 如果系统找不到字体，CTFontCreateWithName 可能会返回回退字体。
        // 我们可以检查返回的字体名称是否与请求的名称匹配。
        let name = CTFontCopyPostScriptName(font) as String
        return name == postscriptName
    }
}
