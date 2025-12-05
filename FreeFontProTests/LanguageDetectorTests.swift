//
//  LanguageDetectorTests.swift
//  FreeFontProTests
//
//  Created by copilot on 2025/12/05.
//

import Testing
import Foundation
@testable import FreeFontPro

struct LanguageDetectorTests {
    
    // MARK: - detectPrimaryLanguageCode Tests
    
    @Test func detectPrimaryLanguageCode_emptyText_returnsEnglish() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "") == "en")
    }
    
    @Test func detectPrimaryLanguageCode_whitespaceOnly_returnsEnglish() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "   ") == "en")
    }
    
    @Test func detectPrimaryLanguageCode_englishOnly_returnsEnglish() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "Hello World") == "en")
    }
    
    @Test func detectPrimaryLanguageCode_simplifiedChinese_returnsZhHans() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "你好世界") == "zh-Hans")
    }
    
    @Test func detectPrimaryLanguageCode_traditionalChinese_returnsZhHant() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "繁體中文測試") == "zh-Hant")
    }
    
    @Test func detectPrimaryLanguageCode_japanese_returnsJa() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "こんにちは") == "ja")
    }
    
    @Test func detectPrimaryLanguageCode_korean_returnsKo() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "안녕하세요") == "ko")
    }
    
    @Test func detectPrimaryLanguageCode_mixedEnglishChinese_returnsChinese() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "Hello, world!你好") == "zh-Hans")
    }
    
    @Test func detectPrimaryLanguageCode_mixedEnglishJapanese_returnsJapanese() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "こんにちは Hello") == "ja")
    }
    
    @Test func detectPrimaryLanguageCode_chineseBeforeJapanese_returnsChinese() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "Hello, world!你好こんにちは") == "zh-Hans")
    }
    
    @Test func detectPrimaryLanguageCode_japaneseBeforeChinese_returnsJapanese() {
        #expect(LanguageDetector.detectPrimaryLanguageCode(for: "Hello, world!こんにちは你好") == "ja")
    }
    
    // MARK: - detectLanguageCodes Tests
    
    @Test func detectLanguageCodes_emptyText_returnsEnglishArray() {
        #expect(LanguageDetector.detectLanguageCodes(for: "") == ["en"])
    }
    
    @Test func detectLanguageCodes_englishOnly_containsEnglish() {
        let codes = LanguageDetector.detectLanguageCodes(for: "Hello World")
        #expect(codes.contains("en"))
    }
    
    @Test func detectLanguageCodes_mixedEnglishChinese_containsBoth() {
        let codes = LanguageDetector.detectLanguageCodes(for: "Hello, world!你好")
        #expect(codes.contains("en"))
        #expect(codes.contains("zh-Hans"))
    }
    
    @Test func detectLanguageCodes_mixedEnglishKorean_containsBoth() {
        let codes = LanguageDetector.detectLanguageCodes(for: "Hello 안녕하세요")
        #expect(codes.contains("en"))
        #expect(codes.contains("ko"))
    }
    
    @Test func detectLanguageCodes_traditionalChinese_containsZhHant() {
        let codes = LanguageDetector.detectLanguageCodes(for: "這是繁體中文")
        #expect(codes.contains("zh-Hant"))
    }
    
    // MARK: - detectPrimaryLanguageName Tests
    
    @Test func detectPrimaryLanguageName_emptyText_returnsEnglish() {
        #expect(LanguageDetector.detectPrimaryLanguageName(for: "") == "English")
    }
    
    @Test func detectPrimaryLanguageName_simplifiedChinese_returnsSimplifiedChineseName() {
        #expect(LanguageDetector.detectPrimaryLanguageName(for: "你好") == "简体中文")
    }
    
    @Test func detectPrimaryLanguageName_japanese_returnsJapaneseName() {
        #expect(LanguageDetector.detectPrimaryLanguageName(for: "こんにちは") == "日本語")
    }
    
    @Test func detectPrimaryLanguageName_korean_returnsKoreanName() {
        #expect(LanguageDetector.detectPrimaryLanguageName(for: "안녕하세요") == "한국어")
    }
    
    // MARK: - displayName Tests
    
    @Test func displayName_englishCode_returnsEnglish() {
        #expect(LanguageDetector.displayName(for: "en") == "English")
    }
    
    @Test func displayName_simplifiedChineseCode_returnsSimplifiedChinese() {
        #expect(LanguageDetector.displayName(for: "zh-Hans") == "简体中文")
    }
    
    @Test func displayName_traditionalChineseCode_returnsTraditionalChinese() {
        #expect(LanguageDetector.displayName(for: "zh-Hant") == "繁體中文")
    }
    
    @Test func displayName_japaneseCode_returnsJapanese() {
        #expect(LanguageDetector.displayName(for: "ja") == "日本語")
    }
    
    @Test func displayName_koreanCode_returnsKorean() {
        #expect(LanguageDetector.displayName(for: "ko") == "한국어")
    }
    
    @Test func displayName_russianCode_returnsRussian() {
        #expect(LanguageDetector.displayName(for: "ru") == "Русский")
    }
}
