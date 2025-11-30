//
//  FontService.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/28.
//

import Foundation

class FreeFontService {
    static let shared = FreeFontService()

    func getFontPreviewUrl(postscriptName: String, inputText: String) -> String {
        return "https://freefont.showtimemaker.com/api/freefont/\(postscriptName)?text=\(inputText)"
    }
}
