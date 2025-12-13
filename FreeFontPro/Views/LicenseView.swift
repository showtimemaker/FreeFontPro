//
//  LicenseView.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/21.
//

import SwiftUI
import SwiftData

struct LicenseView: View {
    let odrTag: FreeFontModel.ODRFile
    @State private var licenseContent: String = "加载中..."
    @State private var isLoading = true
    
    var body: some View {
        
        ScrollView {
            Text(licenseContent)
                .font(.system(size: 12, design: .monospaced))
                .textSelection(.enabled)
                .padding()
        }
        .navigationTitle("许可协议")
        .onAppear {
            loadLicenseFile()
        }
    }
    
    private func loadLicenseFile() {
        isLoading = true
        Task {
            do {
                // 创建 ODR 资源请求
                let request = NSBundleResourceRequest(tags: [odrTag.tag])
                
                // 开始访问 ODR 资源
                try await request.beginAccessingResources()
                
                // 从 ODR Bundle 中加载许可证文件
                if let fileURL = request.bundle.url(forResource: odrTag.name, withExtension: odrTag.ext) {
                    do {
                        let content = try String(contentsOf: fileURL, encoding: .utf8)
                        await MainActor.run {
                            licenseContent = content
                            isLoading = false
                        }
                    } catch {
                        await MainActor.run {
                            licenseContent = "无法加载许可证文件: \(error.localizedDescription)"
                            isLoading = false
                        }
                    }
                } else {
                    await MainActor.run {
                        licenseContent = "许可证文件未找到: \(odrTag.tag).\(odrTag.ext)"
                        isLoading = false
                    }
                }
                
                // 完成资源访问
                // request.endAccessingResources()
            } catch {
                await MainActor.run {
                    licenseContent = "无法访问 ODR 资源: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}




