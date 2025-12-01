import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct FontDetailView: View {
    let font: FreeFontModel
    @AppStorage("previewText") private var previewText: String = "欢迎使用FreeFont Pro"
    @State private var selectedWeight: String = ""
    @State private var selectedLanguage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 字体预览区域
                if let firstVariant = font.postscriptNames.first {
                    FontPreviewSection(
                        postscriptName: firstVariant.postscriptName,
                        previewText: previewText
                    )
                }
                
                // 可下载的字体变体
                if !font.postscriptNames.isEmpty {
                    InfoSection(title: "可用字体") {
                        ForEach(font.postscriptNames) { psName in
                            FontVariantRow(
                                language: psName.language,
                                weight: psName.weight,
                                version: psName.version,
                                fileName: psName.fileName,
                                onDownload: {
                                    if let url = Bundle.main.url(forResource: psName.fileName, withExtension: psName.fileExt) {
                                        Task {
                                            do {
                                                try await FontManager.shared.installFont(from: url)
                                                print("字体安装成功")
                                            } catch {
                                                print("字体安装失败: \(error.localizedDescription)")
                                            }
                                        }
                                    } else {
                                        print("找不到字体文件: \(psName.fileName).\(psName.fileExt)")
                                    }
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
    }
}

// MARK: - 字体预览区域
struct FontPreviewSection: View {
    let postscriptName: String
    let previewText: String
    @State private var retryCount: Int = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("预览")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                WebImage(url: URL(string: FreeFontService.shared.getFontPreviewUrl(
                    postscriptName: postscriptName,
                    inputText: previewText
                ))) { image in
                    if colorScheme == .dark {
                        image.resizable()
                            .colorInvert()
                    } else {
                        image.resizable()
                    }
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                }
                .onFailure { error in
                    print("SVG 加载失败: \(error.localizedDescription)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        retryCount += 1
                    }
                }
                .id(retryCount)
                .transition(.fade(duration: 0.5))
                .scaledToFit()
            }
            .frame(height: 80)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

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
    let onDownload: () -> Void
    
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
            
            Button(action: onDownload) {
                Image(systemName: "arrow.down.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
