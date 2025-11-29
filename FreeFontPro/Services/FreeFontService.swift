//
//  FontService.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/28.
//

import Foundation

class FreeFontService {
    static let shared = FreeFontService()
    private let urlString = "https://freefont.showtimemaker.com/api/freefont/meta/data"
    private let versionUrlString = "https://freefont.showtimemaker.com/api/freefont/meta/version"
    
    func fetchFonts() async throws -> [FontAPIResponse] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([FontAPIResponse].self, from: data)
    }
    
    func fetchVersion() async throws -> String {
        guard let url = URL(string: versionUrlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let version = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw URLError(.cannotDecodeContentData)
        }
        return version
    }

    func getFontPreviewUrl(postscriptName: String, inputText: String) -> String {
        return "https://freefont.showtimemaker.com/api/freefont/\(postscriptName)?text=\(inputText)"
    }
}
