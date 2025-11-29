import SwiftUI

struct FontDetailView: View {
    let font: FreeFontData
    
    var body: some View {
        ScrollView {
            Text(font.nameJSON)
            Text(font.author)
            Text(font.license)
            Text(font.licenseUrl)
            Text(font.copyright)
            Text(font.website)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("下载") {
                    // 下载功能待实现
                }
            }
        }
    }
}

