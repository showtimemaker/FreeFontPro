import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

/// 用于预览字体的卡片视图
/// - 上部：SvgTextView 显示预览字体生成的 SVG 图片，宽度超出屏幕可滚动
/// - 底部：显示字体名称
struct FontPreviewCard: View {
    let previewUrl: URL?
    /// SVG 显示高度
    let svgHeight: CGFloat = 60
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
            ScrollView(.horizontal, showsIndicators: false) {
                Group {
                    if colorScheme == .dark {
                        WebImage(url: previewUrl)
                            .resizable()
                            .scaledToFit()
                            .colorInvert()
                    } else {
                        WebImage(url: previewUrl)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
                .frame(height: svgHeight)
            Spacer(minLength: 24)
            Text(title)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.gray)
                .font(.system(size: 12))
        }
        .padding(EdgeInsets(top: 48, leading: 12, bottom: 32, trailing: 12))
        .contentShape(Rectangle()) // 确保整个区域可点击
        .onTapGesture {
            onTap?()
        }
    }
}
