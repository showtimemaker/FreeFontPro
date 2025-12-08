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

    /// 获取 ODR 预览图片 URL
    /// - Parameter fileName: 字体文件名（不含扩展名）
    /// - Returns: 预览图片 URL，如果不存在则返回 nil
    func getODRPreviewImageURL(fileName: String) async -> URL? {
        let previewTag = "\(fileName)_preview.svg"
        let request = NSBundleResourceRequest(tags: [previewTag])
        
        // 检查资源是否可用
        let isAvailable = await request.conditionallyBeginAccessingResources()
        
        if isAvailable {
            let url = request.bundle.url(forResource: "\(fileName)_preview", withExtension: "svg")
            return url
        }
        
        return nil
    }


    func  checkODRAvailability(tag: String) async ->  Bool {
        let request = NSBundleResourceRequest(tags: [tag])
        let isAvailable = await request.conditionallyBeginAccessingResources()
        if isAvailable {
            request.endAccessingResources()
        }
        return isAvailable
    }

    /// 下载 ODR 资源（带进度回调）
    /// - Parameters:
    ///   - tag: ODR 资源的 tag
    ///   - progressHandler: 进度回调，参数为 0.0 到 1.0 的进度值
    /// - Returns: 下载后的资源 URL
    func downloadODRResource(tag: String, progressHandler: @escaping (Double) -> Void) async throws {
        let request = NSBundleResourceRequest(tags: [tag])
        
        // 创建进度观察任务
        let progressTask = Task {
            while !Task.isCancelled {
                let progress = request.progress.fractionCompleted
                await MainActor.run {
                    progressHandler(progress)
                }
                
                // 如果进度达到 1.0，退出循环
                if progress >= 1.0 {
                    break
                }
                
                // 每 0.1 秒检查一次进度
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
        
        do {
            // 开始访问资源，触发下载
            try await request.beginAccessingResources()
            
            // 最后一次更新进度为 100%
            await MainActor.run {
                progressHandler(1.0)
            }
            
            // 取消进度观察任务
            progressTask.cancel()
            
        } catch {
            progressTask.cancel()
            throw error
        }
    }
    
}
