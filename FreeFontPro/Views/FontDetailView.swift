import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct FontDetailView: View {
    let font: FreeFontModel
    
    var body: some View {
        Form {
            Section ("基本信息"){
                VStack(alignment: .leading, spacing: 4) {
                    Text(font.names[0])
                        .font(.title)
                        .lineLimit(1)
                    Text("作者")
                        .font(.system(size: 12))
                        .bold()
                    Text(font.author)
                        .font(.system(size: 14))
                    Text("版本")
                        .font(.system(size: 12))
                        .bold()
                    Text("version")
                        .font(.system(size: 14))
                    Text("版权")
                        .font(.system(size: 12))
                        .bold()
                    Text(font.copyright)
                        .font(.system(size: 14))
                    Text("Licence")
                        .font(.system(size: 12))
                        .bold()
                    Text(font.license)
                        .font(.system(size: 14))
                }
            }
            Section ("字体样式"){
                Text("字体样式1")
                Text("字体样式2")
            }
        }
        .navigationTitle(font.names[0])
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // 下载字体操作
                } label: {
                    Image(systemName: "arrow.down")
                }  
            }
        }
    }
}
