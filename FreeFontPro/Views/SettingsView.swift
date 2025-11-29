import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = "system"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("useSystemAppearance") private var useSystemAppearance: Bool = true
    
    /// 根据用户设置返回颜色方案
    private var colorScheme: ColorScheme? {
        if useSystemAppearance {
            return nil // 跟随系统
        }
        return isDarkMode ? .dark : .light
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // ...existing code...
                // 语言设置
                Section("语言") {
                    Picker("应用语言", selection: $appLanguage) {
                        Text("跟随系统").tag("system")
                        Text("简体中文").tag("zh-Hans")
                        Text("繁體中文").tag("zh-Hant")
                        Text("日本語").tag("ja")
                        Text("English").tag("en")
                    }
                }
                
                // 外观设置
                Section("外观") {
                    Toggle("跟随系统", isOn: $useSystemAppearance)
                    
                    if !useSystemAppearance {
                        Toggle("夜间模式", isOn: $isDarkMode)
                    }
                }
                
                // 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("构建号")
                        Spacer()
                        Text(buildNumber)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(colorScheme)
    }
    
    /// 获取应用版本号
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// 获取构建号
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

#Preview {
    SettingsView()
}
