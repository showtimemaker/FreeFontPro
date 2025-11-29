//
//  ContentView.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/21.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var fonts: [FreeFontData]
    @AppStorage("fontDataVersion") private var currentVersion: String = ""
    @AppStorage("previewText") private var inputText: String = "欢迎使用FreeFont Pro"
    @State var showInputSheet: Bool = false
    @State private var showSettings: Bool = false
    @State private var selectedFont: FreeFontData? = nil
    @State private var svgHeight: CGFloat = 60
    var body: some View {
        NavigationStack {
            List(fonts) { font in
                FontPreviewCard(
                    svgUrl: FreeFontService.shared.getFontPreviewUrl(
                        postscriptName: "Z-Labs-Bitmap-12px-CN-Regular",
                        inputText: inputText
                    ),
                    svgHeight: svgHeight,
                    title: font.names[0],
                    onTap: {
                        selectedFont = font
                    }
                )
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color(.systemBackground))
            }
            .listStyle(.insetGrouped)
            .navigationDestination(item: $selectedFont) { font in
                FontDetailView(font: font)
            }
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading){
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem (placement: .navigationBarTrailing){
                    Menu("风格") {
                        Button("全部") {
                        }
                        Button("手写体") {
                        }
                        Button("像素体") {
                        }
                        Button("衬线体") {
                        }
                        Button("无衬线体") {
                        }
                        Button("等宽体") {
                        }
                        Button("艺术体") {
                        }
                        Button("书法体") {
                        }
                        Button("黑体") {
                        }
                        Button("宋体") {
                        }
                        Button("圆体") {
                        }
                    }
                }
                ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
                ToolbarItem (placement: .navigationBarTrailing){
                    Menu("语言") {
                        Button("全部") {
                        }
                        Button("简体中文") {
                        }
                        Button("中国香港") {
                        }
                        Button("日本") {
                        }
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
                
                ToolbarSpacer(.fixed, placement: .bottomBar)
                
                ToolbarItem (placement: .bottomBar) {
                    TextField("预览文本", text: $inputText)
                        .disabled(true)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                showInputSheet = true
                            }
                        }
                }
            }
            .fullScreenCover(isPresented: $showInputSheet) {
                PreviewTextInputView(inputText: $inputText)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        do {
            let remoteVersion = try await FreeFontService.shared.fetchVersion()
            if remoteVersion != currentVersion {
                let fetchedFonts = try await FreeFontService.shared.fetchFonts()
                
                // Clear existing data if needed, or update logic. 
                // Here we update existing or insert new ones.
                for fontResponse in fetchedFonts {
                    let id = fontResponse.id
                    let descriptor = FetchDescriptor<FreeFontData>(predicate: #Predicate { $0.id == id })
                    
                    // Delete existing to ensure update
                    if let existing = try modelContext.fetch(descriptor).first {
                        modelContext.delete(existing)
                    }
                    
                    let fontData = fontResponse.toFreeFontData()
                    modelContext.insert(fontData)
                }
                
                currentVersion = remoteVersion
                print("Updated fonts to version: \(remoteVersion)")
            } else {
                print("Fonts are up to date (version: \(currentVersion))")
            }
        } catch {
            print("Failed to fetch fonts or version: \(error)")
        }
    }
}



#Preview {
    HomeView()
        .modelContainer(for: FreeFontData.self, inMemory: true)
}


