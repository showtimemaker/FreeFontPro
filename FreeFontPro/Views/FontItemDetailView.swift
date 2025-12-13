import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct FontItemDetailView: View {
    let ps: FreeFontModel.PostscriptName
    
    var body: some View {
        VStack {
            Button("下载字体") {
                // TODO: 看广告
            }
        }
        .navigationTitle(ps.weight)
    }
}
