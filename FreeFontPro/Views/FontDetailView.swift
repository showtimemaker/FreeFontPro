import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct FontDetailView: View {
    let font: FreeFontModel
    @State private var selectedWeight: String = ""
    @State private var selectedLanguage: String = ""
    @State private var fontStates: [String: FontState] = [:]
    
    enum FontState {
        case checking          // 正在检查
        case needDownload      // 需要下载
        case downloading(Double) // 正在下载（进度）
        case downloaded        // 已下载，可以安装
        case installing        // 正在安装
        case installed         // 已安装
        case error(String)     // 错误状态
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 可下载的字体变体
                if !font.postscriptNames.isEmpty {
                    InfoSection(title: "可用字体") {
                        ForEach(font.postscriptNames) { psName in
                            FontVariantRow(
                                language: psName.language,
                                weight: psName.weight,
                                version: psName.version,
                                fileName: "\(psName.fileName).\(psName.fileExt)",
                                state: fontStates[psName.fileName] ?? .checking,
                                onAction: {
                                    handleFontAction(psName: psName)
                                }
                            )
                        }
                    }
                }
                
                // 基本信息区域
                InfoSection(title: "基本信息") {
                    InfoRow(label: "字体名称", value: font.names[0])
                    if !font.descriptions[0].isEmpty {
                        InfoRow(label: "描述", value: font.descriptions[0])
                    }
                    InfoRow(label: "作者", value: font.author)
                    if !font.categories.isEmpty {
                        InfoRow(label: "风格", value: font.categories.joined(separator: ", "))
                    }
                    if !font.languages.isEmpty {
                        InfoRow(label: "支持语言", value: font.languages.joined(separator: ", "))
                    }
                    if !font.weights.isEmpty {
                        InfoRow(label: "字重", value: font.weights.joined(separator: ", "))
                    }
                }
                
                // 版权信息区域
                InfoSection(title: "版权信息") {
                    InfoRow(label: "许可证", value: font.license)
                    if !font.copyright.isEmpty {
                        InfoRow(label: "版权", value: font.copyright)
                    }
                    if !font.licenseUrl.isEmpty {
                        LinkRow(label: "许可证链接", url: font.licenseUrl)
                    }
                    if !font.website.isEmpty {
                        LinkRow(label: "官方网站", url: font.website)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(font.names[0])
        .navigationBarTitleDisplayMode(.large)
        .task {
            await checkAllFontsStatus()
        }
    }
    
    // MARK: - Helper Methods
    
    /// 检查所有字体的状态
    private func checkAllFontsStatus() async {
        for psName in font.postscriptNames {
            await checkFontStatus(psName: psName)
        }
    }
    
    /// 检查单个字体的状态
    private func checkFontStatus(psName: FreeFontModel.PostscriptName) async {
        fontStates[psName.fileName] = .checking
        
        // 首先检查字体是否已安装
        if FontManager.shared.isFontRegistered(postscriptName: psName.postscriptName) {
            fontStates[psName.fileName] = .installed
            return
        }
        
        // 检查 ODR 资源是否已下载
        if await FreeFontService.shared.checkODRAvailability(tag: "\(psName.fileName).\(psName.fileExt)") {
            fontStates[psName.fileName] = .downloaded
        } else {
            fontStates[psName.fileName] = .needDownload
        }
    }
    
    /// 处理字体操作（下载或安装）
    private func handleFontAction(psName: FreeFontModel.PostscriptName) {
        Task {
            let currentState = fontStates[psName.fileName] ?? .checking
            
            switch currentState {
            case .needDownload:
                await downloadFont(psName: psName)
            case .downloaded:
                await installFont(psName: psName)
            case .installed:
                // 已安装，不做任何操作
                break
            default:
                // 正在处理中，不做任何操作
                break
            }
        }
    }
    
    /// 下载字体
    private func downloadFont(psName: FreeFontModel.PostscriptName) async {
        fontStates[psName.fileName] = .downloading(0.0)
        
        do {
            // 使用带进度回调的下载方法
            try await FreeFontService.shared.downloadODRResource(tag: "\(psName.fileName).\(psName.fileExt)") { progress in
                // 更新下载进度
                self.fontStates[psName.fileName] = .downloading(progress)
            }
            
            fontStates[psName.fileName] = .downloaded
        } catch {
            fontStates[psName.fileName] = .error("下载失败: \(error.localizedDescription)")
            
            // 3秒后重置为需要下载状态
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            fontStates[psName.fileName] = .needDownload
        }
    }
    
    /// 安装字体
    private func installFont(psName: FreeFontModel.PostscriptName) async {
        fontStates[psName.fileName] = .installing
        
        do {
            let tag = "\(psName.fileName).\(psName.fileExt)"
            let request = NSBundleResourceRequest(tags: [tag])
            try await request.beginAccessingResources()
            guard let fontURL = request.bundle.url(forResource: psName.fileName, withExtension: psName.fileExt) else {
                throw NSError(domain: "FontDetailView", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "字体文件未找到"
                ])
            }
            
            // 安装字体
            try await FontManager.shared.installFont(from: fontURL)
            fontStates[psName.fileName] = .installed
            request.endAccessingResources()
        } catch {
            fontStates[psName.fileName] = .error("安装失败: \(error.localizedDescription)")
            
            // 3秒后重置为已下载状态
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            fontStates[psName.fileName] = .downloaded
        }
    }
}

// 移除不需要的扩展

// MARK: - 信息区域容器
struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// MARK: - 信息行
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 链接行
struct LinkRow: View {
    let label: String
    let url: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            if let urlObject = URL(string: url) {
                Link(destination: urlObject) {
                    HStack {
                        Text(url)
                            .font(.body)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                Text(url)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - 字体变体行
struct FontVariantRow: View {
    let language: String
    let weight: String
    let version: String
    let fileName: String
    let state: FontDetailView.FontState
    let onAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(language)
                        .font(.body)
                        .fontWeight(.medium)
                    Text("·")
                        .foregroundColor(.secondary)
                    Text(weight)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(version)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("·")
                        .foregroundColor(.secondary)
                    Text(fileName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 根据状态显示不同的按钮
            Group {
                switch state {
                case .checking:
                    ProgressView()
                        .scaleEffect(0.8)
                    
                case .needDownload:
                    Button(action: onAction) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.circle")
                            Text("下载")
                        }
                        .font(.body)
                        .foregroundColor(.blue)
                    }
                    
                case .downloading(let progress):
                    VStack(spacing: 4) {
                        ProgressView(value: progress)
                            .frame(width: 60)
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                case .downloaded:
                    Button(action: onAction) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                            Text("安装")
                        }
                        .font(.body)
                        .foregroundColor(.green)
                    }
                    
                case .installing:
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("安装中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                case .installed:
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("已安装")
                    }
                    .font(.body)
                    .foregroundColor(.green)
                    
                case .error(let message):
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.red)
                            .lineLimit(2)
                            .multilineTextAlignment(.trailing)
                    }
                    .frame(maxWidth: 150)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
