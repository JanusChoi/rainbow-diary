//
//  DetailView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/4.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import OpenAI
import SwiftUI

struct DetailView: View {
    @State var inputText: String = ""
    @FocusState private var isFocused: Bool
    @State private var showsModelSelectionSheet = false
    @State private var selectedChatModel: Model = .gpt3_5Turbo_16k_0613
    @State private var isEditorExpanded: Bool = false

    private let availableChatModels: [Model] = [.gpt3_5Turbo_16k_0613, .gpt4_0613]

    let conversation: Conversation
    let error: Error?
    let sendMessage: (String, Model) -> Void

    private var fillColor: Color {
        #if os(iOS)
        return Color(uiColor: UIColor.systemBackground)
        #elseif os(macOS)
        return Color(nsColor: NSColor.textBackgroundColor)
        #endif
    }

    private var strokeColor: Color {
        #if os(iOS)
        return Color(uiColor: UIColor.systemGray5)
        #elseif os(macOS)
        return Color(nsColor: NSColor.lightGray)
        #endif
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    if !isEditorExpanded {
                        List {
                            ForEach(conversation.messages) { message in
                                ChatBubble(message: message)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .animation(.default, value: conversation.messages)
                    }
                    

                    if let error = error {
                        errorMessage(error: error)
                    }
                    // Expand or Collapse EditorView
                    Button(action: {
                        isEditorExpanded.toggle()
                    }) {
                        HStack {
                            Text(isEditorExpanded ? "Collapse" : "Expand")
                                .foregroundColor(.black)
                                .cornerRadius(10)
                            if isEditorExpanded {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    .imageScale(.small)
                            }
                            else {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    .imageScale(.small)
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if isEditorExpanded {
                        // 展开状态，显示EditorView
                        EditorView()
                            .transition(.move(edge: .bottom))
                            .animation(.spring(duration: 2.0), value: isEditorExpanded)
                    } else {
                        inputBar(scrollViewProxy: scrollViewProxy)
                    }
                    
                }
//                .navigationTitle("Zen")
            }
        }
    }

    @ViewBuilder private func errorMessage(error: Error) -> some View {
        Text(
            error.localizedDescription
        )
        .font(.caption)
        .foregroundColor({
            #if os(iOS)
            return Color(uiColor: .systemRed)
            #elseif os(macOS)
            return Color(.systemRed)
            #endif
        }())
        .padding(.horizontal)
    }

    @ViewBuilder private func inputBar(scrollViewProxy: ScrollViewProxy) -> some View {
        HStack {
            TextEditor(
                text: $inputText
            )
            .padding(.vertical, -8)
            .padding(.horizontal, -4)
            .frame(minHeight: 22, maxHeight: 300)
            .foregroundColor(.primary)
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .background(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
                .fill(fillColor)
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                    .stroke(
                        strokeColor,
                        lineWidth: 1
                    )
                )
            )
            .fixedSize(horizontal: false, vertical: true)
            .onSubmit {
                withAnimation {
                    tapSendMessage(scrollViewProxy: scrollViewProxy)
                }
            }
            .padding(.leading)

            Button(action: {
                withAnimation {
                    tapSendMessage(scrollViewProxy: scrollViewProxy)
                }
            }) {
                Image(systemName: "paperplane")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(.trailing)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.bottom)
    }
    
    private func tapSendMessage(
        scrollViewProxy: ScrollViewProxy
    ) {
        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if message.isEmpty {
            return
        }
        print(message)
        print(selectedChatModel)
        sendMessage(message, selectedChatModel)
        inputText = ""
        
    }
}

struct ChatBubble: View {
    let message: Message

    private var assistantBackgroundColor: Color {
        #if os(iOS)
        return Color(uiColor: UIColor.systemGray5)
        #elseif os(macOS)
        return Color(nsColor: NSColor.lightGray)
        #endif
    }

    private var userForegroundColor: Color {
        #if os(iOS)
        return Color(uiColor: .white)
        #elseif os(macOS)
        return Color(nsColor: NSColor.white)
        #endif
    }

    private var userBackgroundColor: Color {
        #if os(iOS)
        return Color(uiColor: .systemBlue)
        #elseif os(macOS)
        return Color(nsColor: NSColor.systemBlue)
        #endif
    }

    var body: some View {
        HStack {
            switch message.role {
            case .assistant:
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(assistantBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                Spacer(minLength: 24)
            case .user:
                Spacer(minLength: 24)
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .foregroundColor(userForegroundColor)
                    .background(userBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            case .function:
              Text(message.content)
                  .font(.footnote.monospaced())
                  .padding(.horizontal, 16)
                  .padding(.vertical, 12)
                  .background(assistantBackgroundColor)
                  .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
              Spacer(minLength: 24)
            case .system:
                EmptyView()
            }
        }
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(
//            conversation: Conversation(
//                id: "1",
//                messages: [
//                    Message(id: "1", role: .assistant, content: "Hello, how can I help you today?", createdAt: Date(timeIntervalSinceReferenceDate: 0)),
//                    Message(id: "2", role: .user, content: "I need help with my subscription.", createdAt: Date(timeIntervalSinceReferenceDate: 100)),
//                    Message(id: "3", role: .assistant, content: "Sure, what seems to be the problem with your subscription?", createdAt: Date(timeIntervalSinceReferenceDate: 200)),
//                    Message(id: "4", role: .function, content:
//                              """
//                              get_current_weather({
//                                "location": "Glasgow, Scotland",
//                                "format": "celsius"
//                              })
//                              """, createdAt: Date(timeIntervalSinceReferenceDate: 200))
//                ]
//            ),
//            error: nil,
//            sendMessage: { _, _ in }
//        )
//    }
//}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            conversation: Conversation(
                id: "1",
                messages: [
                    Message(id: "1", role: .assistant, content: "Hello, how can I help you today?", createdAt: Date(timeIntervalSinceReferenceDate: 0))
                ]
            ), error: nil, sendMessage: { _, _ in }
        )
    }
}
