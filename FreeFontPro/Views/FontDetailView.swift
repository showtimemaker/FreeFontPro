import SwiftUI

struct FontDetailView: View {
    let font: FontData
    
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
                    // 分享功能待实现
                }
            }
        }
    }
}

