//
//  EditorView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/29.
//

import SwiftUI
import MarkdownKit

struct EditorView: View {
    @State private var text: String = ""
    @State private var isMarkdown: Bool = true
    @StateObject private var speechStore = SpeechStore()
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            editorView
            editorToolbar
        }
    }
    
    private var editorToolbar: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: toggleEditor) {
                    Image(systemName: "book").imageScale(.large)
                }
                Text(isMarkdown ? "MD#":"Rich")
            }
            Spacer()
            VStack {
                Button(action: addImage) {
                    Image(systemName: "photo").imageScale(.large)
                }
                Text("Pic")
            }
            Spacer()
            VStack {
//                Button(action: recordAudio) {
//                    Image(systemName: "mic").imageScale(.large)
//                }
//                Text("Speak")
                Button(action: {
                    self.isRecording.toggle()
                    if self.isRecording {
                        try? self.speechStore.startRecording()
                    } else {
                        self.speechStore.stopRecording()
                    }
                }) {
                    Image(systemName: "mic").imageScale(.large)
//                    Text(isRecording ? "Release to go" : "Hold to speak")
                }
//                .padding()
//                .background(isRecording ? Color.red : Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
                Text("Speak")
            }
            Spacer()
            // 其他按钮可以放置在这里
        }
        .padding(.horizontal)
    }
    
    private var editorView: some View {
        Group {
            if isMarkdown {
                MarkdownEditorView(text: $text)
            } else {
                RichTextEditorView(text: $text)
            }
        }
    }
    
    private func toggleEditor() {
        isMarkdown.toggle()
    }
    
    private func addImage() {
        // 实现图片添加功能
    }
    
    private func recordAudio() {
        // 实现录音功能
    }
}

struct MarkdownEditorView: View {
    @Binding var text: String
    
    var body: some View {
        TextEditor(text: $text)
            .border(Color.gray, width: 1)
            .padding()
    }
}

struct RichTextEditorView: View {
    @Binding var text: String
    
    var body: some View {
        TextEditor(text: $text)
            .border(Color.gray, width: 1)
            .padding()
    }
}

// 预览部分
struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
