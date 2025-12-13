import SwiftUI


struct FreeFontModel: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let categories: [String]
    let languages: [String]
    let names: [String]
    let descriptions: [String]
    let weights: [String]
    let license: String
    let licenseUrl: String
    let website: String
    let copyright: String
    let version: String
    let licenseFile: ODRFile
    let preview: LocalFile
    let postscriptNames: [PostscriptName]
    
    struct PostscriptName: Hashable {
        let postscriptName: String
        let weight: String
        let style: String
        let fileName: String
        let fileExt: String
    }

    struct LocalFile: Hashable {
        let name: String
        let ext: String
    }
    
    struct ODRFile: Hashable {
        let tag: String
        let name: String
        let ext: String
    }
}
