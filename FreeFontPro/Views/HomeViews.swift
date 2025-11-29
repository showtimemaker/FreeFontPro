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
    @Query private var fonts: [FontData]
    @AppStorage("fontDataVersion") private var currentVersion: String = ""
    @AppStorage("previewText") private var inputText: String = "你好"
    @State var showInputSheet: Bool = false
    var body: some View {
        NavigationStack {
            List(fonts) { font in
                NavigationLink {
                    FontDetailView()
                } label: {
                    FontPreviewCard(
                        svgUrl: "https://freefont.showtimemaker.com/api/freefont/Z-Labs-Bitmap-12px-CN-Regular?text=\(inputText)",
                        svgHeight: 60,
                        title: font.nameJSON
                    )
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing){
                    Button("类别") {
                        
                    }
                }
                ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
                ToolbarItem (placement: .navigationBarTrailing){
                    Menu{
                        Button("全部") {
                        }
                        Button("中国大陆") {
                        }
                        Button("中国香港") {
                        }
                        Button("日本") {
                        }
                    } label: {
                        Image(systemName: "globe")
                    }
                }
                ToolbarItem (placement: .bottomBar) {
                    Menu{
                        Button("小") {
                        }
                        Button("中") {
                        }
                        Button("大") {
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
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        do {
            let remoteVersion = try await FontService.shared.fetchVersion()
            if remoteVersion != currentVersion {
                let fetchedFonts = try await FontService.shared.fetchFonts()
                
                // Clear existing data if needed, or update logic. 
                // Here we update existing or insert new ones.
                for fontResponse in fetchedFonts {
                    let id = fontResponse.id
                    let descriptor = FetchDescriptor<FontData>(predicate: #Predicate { $0.id == id })
                    
                    // Delete existing to ensure update
                    if let existing = try modelContext.fetch(descriptor).first {
                        modelContext.delete(existing)
                    }
                    
                    let fontData = fontResponse.toFontData()
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
        .modelContainer(for: FontData.self, inMemory: true)
}


