import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct FontDetailView: View {
    let font: FreeFontModel
    @State private var showLicenseView = false
    @State private var selectedPostscript: FreeFontModel.PostscriptName? = nil
    
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
                    Text(font.version)
                        .font(.system(size: 14))
                    Text("版权")
                        .font(.system(size: 12))
                        .bold()
                    Text(font.copyright)
                        .font(.system(size: 14))
                    Text("许可协议")
                        .font(.system(size: 12))
                        .bold()
                    Button(action: { showLicenseView = true }) {
                        Text(font.license)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                }
                .navigationDestination(isPresented: $showLicenseView) {
                    LicenseView(odrTag: font.licenseFile)
                }
            }
            Section ("\(font.postscriptNames.count)种样式"){
                ForEach(font.postscriptNames, id: \.postscriptName) { ps in
                    NavigationLink(destination: FontItemDetailView(ps: ps)) {
                        Text(ps.weight)
                                .font(.system(size: 14))
                                .bold()
                    }
                }
            }
        }
        .navigationTitle(font.names[0])
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO: 只能购买才能使用
                } label: {
                    Image(systemName: "arrow.down")
                }  
            }
        }
    }
}
