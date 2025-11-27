//
//  ContentView.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/21.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var inputText: String = ""
    @State var showInputSheet: Bool = false
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    Button("install Font") {
                        print("install Font")
                    }
                } label: {
                    Text("Hello, world!")
                }
            }
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
                TextInputView(inputText: $inputText)
            }
        }
    }
    
}

// MARK: - 文本输入页面
struct TextInputView: View {
    @Binding var inputText: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool
    
    // 快捷输入文本
    private let quickTexts = [
        "永",
        "永字八法",
        "天地玄黄",
        "The quick brown fox jumps over the lazy dog",
        "0123456789",
        "你好世界",
        "春眠不觉晓",
        "锄禾日当午，汗滴禾下土",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    ]
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 0) {
                // 快捷输入文本区域
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(quickTexts, id: \.self) { text in
                            Button {
                                inputText = text
                                isInputFocused = false
                                dismiss()
                            } label: {
                                HStack {
                                    Text(text)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isInputFocused = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    TextField("预览文本", text: $inputText)
                        .focused($isInputFocused)
                        .padding(.horizontal, 16)
                }
                ToolbarSpacer(.fixed, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button("完成") {
                        isInputFocused = false
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                isInputFocused = true
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
