//
//  TextInputView.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/28.
//

import SwiftUI


struct PreviewTextInputView: View {
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
    TextInputView(inputText: .constant("预览文本"))
}
