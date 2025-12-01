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


    func checkODRAvailability(forResource: String, withExtension: String) -> Bool {
        return nil != Bundle.main.url(forResource: forResource, withExtension: withExtension)
    }

    func downloadODRResource(tag: String) async throws -> URL {
        let request = NSBundleResourceRequest(tags: [tag])
        try await request.beginAccessingResources()
        guard let url = Bundle.main.url(forResource: tag, withExtension: "ttf") else {
            request.endAccessingResources()
            throw NSError(domain: "FreeFontService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Resource not found"])
        }
        return url
    }
}
