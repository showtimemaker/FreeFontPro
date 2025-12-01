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
    let postscriptNames: [PostscriptName]
    
    struct PostscriptName: Identifiable, Hashable {
        let id = UUID()
        let language: String
        let weight: String
        let postscriptName: String
        let fileName: String
        let fileExt: String
        let version: String
    }
}
