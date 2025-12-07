//
//  LanguageDetector.swift
//  FreeFont Pro
//
//  Created by copilot on 2025/12/05.
//

import Foundation
import NaturalLanguage

/// 语言检测工具
/// 提供返回语言 code（如 "en", "zh-Hans"）和人类可读名称的便捷方法
enum LanguageDetector {
    /// 返回检测到的所有语言代码（BCP-47 like）
    /// 结合 NLLanguageRecognizer 和 Unicode 范围检测，以更好地处理混合语言文本
    /// - Parameters:
    ///   - text: 要检测的文本
    ///   - threshold: NL 置信度阈值（0.0-1.0），默认 0.1
    /// - Returns: 语言代码数组（例如 ["en", "zh-Hans"]），去重后返回
    static func detectLanguageCodes(for text: String, threshold: Double = 0.1) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ["en"] }
        
        var detectedLanguages = Set<String>()
        
        // 方法1: 使用 NLLanguageRecognizer
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(trimmed)
        let hypotheses = recognizer.languageHypotheses(withMaximum: 10)
        for (lang, confidence) in hypotheses where confidence >= threshold {
            detectedLanguages.insert(lang.rawValue)
        }
        
        // 方法2: 基于 Unicode 范围检测（用于补充 NL 可能漏掉的语言）
        // 传入 NL 识别的繁体中文标志
        let isTraditionalChinese = hypotheses.keys.contains(.traditionalChinese)
        let unicodeDetected = detectLanguagesByUnicode(text: trimmed, isTraditionalChinese: isTraditionalChinese)
        detectedLanguages.formUnion(unicodeDetected)
        
        return Array(detectedLanguages).sorted()
    }
    
    /// 基于 Unicode 字符范围检测语言
    private static func detectLanguagesByUnicode(text: String, isTraditionalChinese: Bool = false) -> Set<String> {
        var languages = Set<String>()
        
        for scalar in text.unicodeScalars {
            let value = scalar.value
            
            // CJK 统一汉字 (中文) - 根据 NL 识别结果区分简繁体
            if (0x4E00...0x9FFF).contains(value) ||    // CJK Unified Ideographs
               (0x3400...0x4DBF).contains(value) ||    // CJK Unified Ideographs Extension A
               (0x20000...0x2A6DF).contains(value) ||  // CJK Unified Ideographs Extension B
               (0x2A700...0x2B73F).contains(value) ||  // CJK Unified Ideographs Extension C
               (0x2B740...0x2B81F).contains(value) ||  // CJK Unified Ideographs Extension D
               (0xF900...0xFAFF).contains(value) {     // CJK Compatibility Ideographs
                languages.insert(isTraditionalChinese ? "zh-Hant" : "zh-Hans")
            }
            // 日文平假名和片假名
            else if (0x3040...0x309F).contains(value) ||  // Hiragana
                    (0x30A0...0x30FF).contains(value) ||  // Katakana
                    (0x31F0...0x31FF).contains(value) {   // Katakana Phonetic Extensions
                languages.insert("ja")
            }
            // 韩文
            else if (0xAC00...0xD7AF).contains(value) ||  // Hangul Syllables
                    (0x1100...0x11FF).contains(value) ||  // Hangul Jamo
                    (0x3130...0x318F).contains(value) {   // Hangul Compatibility Jamo
                languages.insert("ko")
            }
            // 拉丁字母 (英文等)
            else if (0x0041...0x007A).contains(value) ||  // Basic Latin letters
                    (0x00C0...0x024F).contains(value) {   // Latin Extended
                languages.insert("en")
            }
            // 西里尔字母 (俄文等)
            else if (0x0400...0x04FF).contains(value) {
                languages.insert("ru")
            }
            // 阿拉伯字母
            else if (0x0600...0x06FF).contains(value) ||
                    (0x0750...0x077F).contains(value) {
                languages.insert("ar")
            }
            // 泰文
            else if (0x0E00...0x0E7F).contains(value) {
                languages.insert("th")
            }
            // 希腊字母
            else if (0x0370...0x03FF).contains(value) {
                languages.insert("el")
            }
            // 希伯来文
            else if (0x0590...0x05FF).contains(value) {
                languages.insert("he")
            }
        }
        
        return languages
    }
    
    /// 返回最可能的语言代码（BCP-47 like）
    /// - Parameter text: 要检测的文本
    /// - Returns: 语言代码（例如 "en", "zh-Hans"），或者 nil 如果无法识别或文本为空
    static func detectLanguageCode(for text: String) -> String? {
        return detectLanguageCodes(for: text).first
    }
    
    /// 返回主要语言代码（优先非英文语言，按出现顺序）
    /// 当检测到多种语言时，返回文本中第一个出现的非英文语言
    /// - Parameter text: 要检测的文本
    /// - Returns: 主要语言代码，文本为空时返回 "en"
    static func detectPrimaryLanguageCode(for text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "en" }
        
        // 使用 NLLanguageRecognizer 检测是否为繁体中文
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(trimmed)
        let hypotheses = recognizer.languageHypotheses(withMaximum: 5)
        let isTraditionalChinese = hypotheses.keys.contains(.traditionalChinese)
        
        // 按文本中字符出现顺序检测第一个非英文语言
        for scalar in trimmed.unicodeScalars {
            let value = scalar.value
            
            // CJK 统一汉字 (中文) - 根据 NL 识别结果区分简繁体
            if (0x4E00...0x9FFF).contains(value) ||
               (0x3400...0x4DBF).contains(value) ||
               (0x20000...0x2A6DF).contains(value) ||
               (0x2A700...0x2B73F).contains(value) ||
               (0x2B740...0x2B81F).contains(value) ||
               (0xF900...0xFAFF).contains(value) {
                return isTraditionalChinese ? "zh-Hant" : "zh-Hans"
            }
            // 日文平假名和片假名
            if (0x3040...0x309F).contains(value) ||
               (0x30A0...0x30FF).contains(value) ||
               (0x31F0...0x31FF).contains(value) {
                return "ja"
            }
            // 韩文
            if (0xAC00...0xD7AF).contains(value) ||
               (0x1100...0x11FF).contains(value) ||
               (0x3130...0x318F).contains(value) {
                return "ko"
            }
            // 西里尔字母 (俄文等)
            if (0x0400...0x04FF).contains(value) {
                return "ru"
            }
            // 阿拉伯字母
            if (0x0600...0x06FF).contains(value) ||
               (0x0750...0x077F).contains(value) {
                return "ar"
            }
            // 泰文
            if (0x0E00...0x0E7F).contains(value) {
                return "th"
            }
            // 希腊字母
            if (0x0370...0x03FF).contains(value) {
                return "el"
            }
            // 希伯来文
            if (0x0590...0x05FF).contains(value) {
                return "he"
            }
        }
        
        // 如果没有非英文语言，返回英文
        return "en"
    }
    
    /// 返回主要语言名称（优先非英文语言）
    /// - Parameter text: 要检测的文本
    /// - Returns: 主要语言的可读名称
    static func detectPrimaryLanguageName(for text: String) -> String {
        return displayName(for: detectPrimaryLanguageCode(for: text))
    }

    /// 返回检测到的所有语言名称
    /// - Parameters:
    ///   - text: 要检测的文本
    ///   - threshold: 置信度阈值（0.0-1.0），默认 0.1
    /// - Returns: 可读的语言名称数组（例如 ["English", "简体中文"]）
    static func detectLanguageNames(for text: String, threshold: Double = 0.1) -> [String] {
        return detectLanguageCodes(for: text, threshold: threshold).map { displayName(for: $0) }
    }
    
    /// 返回本地化的语言名称（更适合显示给用户）
    /// - Parameter text: 要检测的文本
    /// - Returns: 可读的语言名称（例如 "简体中文", "日本語", "English"），找不到时返回 nil
    static func detectLanguageName(for text: String) -> String? {
        guard let code = detectLanguageCode(for: text) else { return nil }
        return displayName(for: code)
    }

    /// 将语言代码映射为更友好的显示名称
    static func displayName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "zh-Hans": return "简体中文"
        case "zh-Hant": return "繁體中文"
        case "zh": return "中文"
        case "ja": return "日本語"
        case "ko": return "한국어"
        case "es": return "Español"
        case "fr": return "Français"
        case "de": return "Deutsch"
        case "ru": return "Русский"
        case "ar": return "العربية"
        default:
            // 使用系统 Locale 尝试本地化名称，回退为 code 本身
            return Locale.current.localizedString(forLanguageCode: code) ?? code
        }
    }
}
