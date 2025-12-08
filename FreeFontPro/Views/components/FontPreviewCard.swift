import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

/// 用于预览字体的卡片视图
/// - 上部：SvgTextView 显示预览字体生成的 SVG 图片，宽度超出屏幕可滚动
/// - 底部：显示字体名称
struct FontPreviewCard: View {
    /// ODR 资源标签
    let previewTag: String
    /// SVG 显示高度
    let svgHeight: CGFloat
    /// 字体名称
    let title: String
    /// 点击回调
    var onTap: (() -> Void)? = nil
    
    @State private var svgUrl: URL?
    @State private var isLoading = true
    @State private var retryCount = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            // 上部：SVG 预览区域，水平可滚动
            ScrollView(.horizontal, showsIndicators: false) {
                Group {
                    if let url = svgUrl {
                        WebImage(url: url) { image in
                            if colorScheme == .dark {
                                image.resizable()
                                    .colorInvert()
                            } else {
                                image.resizable()
                            }
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .onFailure { error in
                            print("SVG 加载失败: \(error.localizedDescription)")
                            // 3 秒后重试
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                retryCount += 1
                            }
                        }
                        .id(retryCount)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                    } else if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(height: svgHeight)
            .background(Color(uiColor: .systemBackground))
            Text(title)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .foregroundColor(.gray)
                .font(.system(size: 12))
        }
        .contentShape(Rectangle()) // 确保整个区域可点击
        .onTapGesture {
            onTap?()
        }
        .task {
            await loadODRResource()
        }
        .onChange(of: retryCount) { _ in
            Task {
                await loadODRResource()
            }
        }
    }
    
    /// 加载 ODR 资源
    private func loadODRResource() async {
        isLoading = true
        
        let request = NSBundleResourceRequest(tags: [previewTag])
        
        do {
            // 请求 ODR 资源
            try await request.beginAccessingResources()
            
            // 查找 SVG 文件
            if let resourceURL = request.bundle.url(forResource: previewTag, withExtension: "svg") {
                svgUrl = resourceURL
            } else {
                print("未找到 ODR 资源: \(previewTag)")
                // 3 秒后重试
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    retryCount += 1
                }
            }
            
            isLoading = false
            
        } catch {
            print("加载 ODR 资源失败: \(error.localizedDescription)")
            isLoading = false
            // 3 秒后重试
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                retryCount += 1
            }
        }
    }
}

#Preview {
    FontPreviewCard(
        previewTag: "ZLabsBitmap_12px_CN_preview_cn",
        svgHeight: 100,
        title: "Z Labs Bitmap 12px CN"
    )
    .padding()
}
