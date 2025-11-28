//
//  DownloadService.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/28.
//

import Foundation

class DownloadService {
    static let shared = DownloadService()
    
    private init() {}
    
    /// 下载文件并保存到 Documents 目录
    /// - Parameter url: 文件的远程 URL
    /// - Returns: 下载后的本地文件 URL
    func downloadFile(from url: URL) async throws -> URL {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        
        // 如果文件已存在，先删除
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.moveItem(at: tempURL, to: destinationURL)
        
        return destinationURL
    }
}
