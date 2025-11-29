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
    
    // Store complex types as JSON strings to ensure SwiftData compatibility
    var nameJSON: String
    var descriptionJSON: String
    var postscriptNamesJSON: String
    
    init(id: String, categories: [String], languages: [String], author: String, weights: [String], license: String, licenseUrl: String, website: String, copyright: String, nameJSON: String, descriptionJSON: String, postscriptNamesJSON: String) {
        self.id = id
        self.categories = categories
        self.languages = languages
        self.author = author
        self.weights = weights
        self.license = license
        self.licenseUrl = licenseUrl
        self.website = website
        self.copyright = copyright
        self.nameJSON = nameJSON
        self.descriptionJSON = descriptionJSON
        self.postscriptNamesJSON = postscriptNamesJSON
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
        let nameData = (try? JSONEncoder().encode(name)) ?? Data()
        let nameJSON = String(data: nameData, encoding: .utf8) ?? "{}"
        
        let descData = (try? JSONEncoder().encode(description)) ?? Data()
        let descJSON = String(data: descData, encoding: .utf8) ?? "{}"
        
        let postData = (try? JSONEncoder().encode(postscriptNames)) ?? Data()
        let postJSON = String(data: postData, encoding: .utf8) ?? "[]"
        
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
            nameJSON: nameJSON,
            descriptionJSON: descJSON,
            postscriptNamesJSON: postJSON
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
