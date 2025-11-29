//
//  FontData.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/28.
//

import Foundation
import SwiftData

@Model
final class FreeFontData {
    @Attribute(.unique) var id: String
    var categories: [String]
    var languages: [String]
    var author: String
    var weights: [String]
    var license: String
    var licenseUrl: String
    var website: String
    var copyright: String
    
    // 多语言名称和描述，只存储 value
    var names: [String]
    var descriptions: [String]
    
    // 使用 Model 存储 PostscriptName
    @Relationship(deleteRule: .cascade)
    var postscriptNames: [PostscriptNameData]
    
    init(id: String, categories: [String], languages: [String], author: String, weights: [String], license: String, licenseUrl: String, website: String, copyright: String, names: [String], descriptions: [String], postscriptNames: [PostscriptNameData]) {
        self.id = id
        self.categories = categories
        self.languages = languages
        self.author = author
        self.weights = weights
        self.license = license
        self.licenseUrl = licenseUrl
        self.website = website
        self.copyright = copyright
        self.names = names
        self.descriptions = descriptions
        self.postscriptNames = postscriptNames
    }
    
    /// 获取本地化名称（第一个非空名称）
    var localizedName: String {
        names.first { !$0.isEmpty } ?? id
    }
    
    /// 获取本地化描述（第一个非空描述）
    var localizedDescription: String {
        descriptions.first { !$0.isEmpty } ?? ""
    }
}

/// PostscriptName 数据模型
@Model
final class PostscriptNameData {
    var language: String
    var weight: String
    var postscriptName: String
    var downloadUrls: [String]
    var sha512: String
    var size: Int
    var version: String
    
    init(language: String, weight: String, postscriptName: String, downloadUrls: [String], sha512: String, size: Int, version: String) {
        self.language = language
        self.weight = weight
        self.postscriptName = postscriptName
        self.downloadUrls = downloadUrls
        self.sha512 = sha512
        self.size = size
        self.version = version
    }
}

// Helper structs for API decoding
struct FontAPIResponse: Codable {
    let id: String
    let categories: [String]
    let languages: [String]
    let name: [String: String]
    let author: String
    let weights: [String]
    let description: [String: String]
    let license: String
    let licenseUrl: String
    let website: String
    let copyright: String
    let postscriptNames: [PostscriptName]
    
    func toFreeFontData() -> FreeFontData {
        // 只取 name 和 description 的 values
        let names = Array(name.values)
        let descriptions = Array(description.values)
        
        // 转换 PostscriptName 为 PostscriptNameData
        let postscriptNamesData = postscriptNames.map { item in
            PostscriptNameData(
                language: item.language,
                weight: item.weight,
                postscriptName: item.postscriptName,
                downloadUrls: item.downloadUrls,
                sha512: item.sha512,
                size: item.size,
                version: item.version
            )
        }
        
        return FreeFontData(
            id: id,
            categories: categories,
            languages: languages,
            author: author,
            weights: weights,
            license: license,
            licenseUrl: licenseUrl,
            website: website,
            copyright: copyright,
            names: names,
            descriptions: descriptions,
            postscriptNames: postscriptNamesData
        )
    }
}

struct PostscriptName: Codable {
    let language: String
    let weight: String
    let postscriptName: String
    let downloadUrls: [String]
    let sha512: String
    let size: Int
    let version: String
}
