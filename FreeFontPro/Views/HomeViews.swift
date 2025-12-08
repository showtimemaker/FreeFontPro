//
//  ContentView.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/21.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    private var fonts = FreeFont
    @AppStorage("fontDataVersion") private var currentVersion: String = ""
    @AppStorage("previewText") private var inputText: String = "欢迎使用FreeFont Pro"
    @State var showInputSheet: Bool = false
    @State private var selectedFont: FreeFontModel? = nil
    @State private var svgHeight: CGFloat = 60
    @State private var selectedCategory: String = "all"
    @State private var selectedLanguage: String = "all"
    @Environment(\.colorScheme) private var colorScheme
    
    // 过滤后的字体列表
    private var filteredFonts: [FreeFontModel] {
        fonts.filter { font in
            let categoryMatch = selectedCategory == "all" || font.categories.contains(selectedCategory)
            let languageMatch = selectedLanguage == "all" || font.languages.contains(selectedLanguage)
            return categoryMatch && languageMatch
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredFonts) { font in
                FontPreviewCard(
                    previewTag: font.postscriptNames.first?.previewTag ?? "",
                    svgHeight: svgHeight,
                    title: font.names[0],
                    onTap: {
                        selectedFont = font
                    }
                )
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(item: $selectedFont) { font in
                FontDetailView(font: font)
            }
            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing){
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem (placement: .bottomBar){
                    Menu {
                        Button {
                            selectedLanguage = "all"
                        } label: {
                            if selectedLanguage == "all" {
                                Label("全部", systemImage: "checkmark")
                            } else {
                                Text("全部")
                            }
                        }
                        Button {
                            selectedLanguage = "zh-Hans"
                        } label: {
                            if selectedLanguage == "zh-Hans" {
                                Label("简体中文", systemImage: "checkmark")
                            } else {
                                Text("简体中文")
                            }
                        }
                        Button {
                            selectedLanguage = "zh-Hant"
                        } label: {
                            if selectedLanguage == "zh-Hant" {
                                Label("繁体中文", systemImage: "checkmark")
                            } else {
                                Text("繁体中文")
                            }
                        }
                        Button {
                            selectedLanguage = "ja"
                        } label: {
                            if selectedLanguage == "ja" {
                                Label("日本語", systemImage: "checkmark")
                            } else {
                                Text("日本語")
                            }
                        }
                    } label: {
                        Label("语言", systemImage: "globe")
                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem (placement: .bottomBar){
                    Menu {
                        Button {
                            selectedCategory = "all"
                        } label: {
                            if selectedCategory == "all" {
                                Label("全部", systemImage: "checkmark")
                            } else {
                                Text("全部")
                            }
                        }
                        Button {
                            selectedCategory = "handwriting"
                        } label: {
                            if selectedCategory == "handwriting" {
                                Label("手写体", systemImage: "checkmark")
                            } else {
                                Text("手写体")
                            }
                        }
                        Button {
                            selectedCategory = "pixel"
                        } label: {
                            if selectedCategory == "pixel" {
                                Label("像素体", systemImage: "checkmark")
                            } else {
                                Text("像素体")
                            }
                        }
                        Button {
                            selectedCategory = "serif"
                        } label: {
                            if selectedCategory == "serif" {
                                Label("衬线体", systemImage: "checkmark")
                            } else {
                                Text("衬线体")
                            }
                        }
                        Button {
                            selectedCategory = "sans-serif"
                        } label: {
                            if selectedCategory == "sans-serif" {
                                Label("无衬线体", systemImage: "checkmark")
                            } else {
                                Text("无衬线体")
                            }
                        }
                        Button {
                            selectedCategory = "monospace"
                        } label: {
                            if selectedCategory == "monospace" {
                                Label("等宽体", systemImage: "checkmark")
                            } else {
                                Text("等宽体")
                            }
                        }
                        Button {
                            selectedCategory = "artistic"
                        } label: {
                            if selectedCategory == "artistic" {
                                Label("艺术体", systemImage: "checkmark")
                            } else {
                                Text("艺术体")
                            }
                        }
                        Button {
                            selectedCategory = "calligraphy"
                        } label: {
                            if selectedCategory == "calligraphy" {
                                Label("书法体", systemImage: "checkmark")
                            } else {
                                Text("书法体")
                            }
                        }
                        Button {
                            selectedCategory = "gothic"
                        } label: {
                            if selectedCategory == "gothic" {
                                Label("黑体", systemImage: "checkmark")
                            } else {
                                Text("黑体")
                            }
                        }
                        Button {
                            selectedCategory = "song"
                        } label: {
                            if selectedCategory == "song" {
                                Label("宋体", systemImage: "checkmark")
                            } else {
                                Text("宋体")
                            }
                        }
                        Button {
                            selectedCategory = "rounded"
                        } label: {
                            if selectedCategory == "rounded" {
                                Label("圆体", systemImage: "checkmark")
                            } else {
                                Text("圆体")
                            }
                        }
                    } label: {
                        Label("风格", systemImage: "scribble.variable")
                    }
                }
                ToolbarItem (placement: .bottomBar) {
                    Menu{
                        Button {
                            svgHeight = 60
                        } label: {
                            Label("小", systemImage: "textformat.size.smaller")
                        }
                        Button {
                            svgHeight = 80
                        } label: {
                            Label("中", systemImage: "textformat.size")
                        }
                        Button {
                            svgHeight = 100
                        } label: {
                            Label("大", systemImage: "textformat.size.larger")
                        }
                    } label: {
                        Image(systemName: "textformat.size")
                    }
                }
                
                // ToolbarItem (placement: .bottomBar) {
                //     TextField("预览文本", text: $inputText)
                //         .disabled(true)
                //         .padding(.horizontal, 16)
                //         .contentShape(Rectangle())
                //         .onTapGesture {
                //             var transaction = Transaction()
                //             transaction.disablesAnimations = true
                //             withTransaction(transaction) {
                //                 showInputSheet = true
                //             }
                //         }
                // }
            }
        }
    }
}



#Preview {
    HomeView()
}


