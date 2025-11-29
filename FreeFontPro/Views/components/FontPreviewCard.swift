import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

/// 用于预览字体的卡片视图
/// - 上部：SvgTextView 显示预览字体生成的 SVG 图片，宽度超出屏幕可滚动
/// - 底部：显示字体名称
struct FontPreviewCard: View {
    /// SVG URL 地址
    let svgUrl: String
    /// SVG 显示高度
    let svgHeight: CGFloat
    /// 字体名称
    let title: String
    /// 点击回调
    var onTap: (() -> Void)? = nil
    
    @State private var retryCount: Int = 0
    
    var body: some View {
        VStack {
            // 上部：SVG 预览区域，水平可滚动
            ScrollView(.horizontal, showsIndicators: false) {
                WebImage(url: URL(string: svgUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .onFailure { error in
                    print("SVG 加载失败: \(error.localizedDescription)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        retryCount += 1
                    }
                }
                .id(retryCount) // 改变 id 触发重新加载
                .transition(.fade(duration: 0.5))
                .scaledToFit()
            }
            .frame(height: svgHeight)
            Text(title)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .foregroundColor(.gray)
                .font(.system(size: 12))
        }
        .background(Color.white)
        .contentShape(Rectangle()) // 确保整个区域可点击
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    FontPreviewCard(
        svgUrl: "https://freefont.showtimemaker.com/api/freefont/Z-Labs-Bitmap-12px-CN-Regular?text=你好就是好",
        svgHeight: 100,
        title: "思源黑体"
    )
    .padding()
}
