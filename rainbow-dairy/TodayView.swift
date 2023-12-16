//
//  TodayView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/16.
//

import SwiftUI

struct TodayView: View {
    @State private var messageText: String = ""
    @State private var messages: [(text: String, isUser: Bool, date: Date)] = []
    @State private var isTextFieldVisible: Bool = true
    @EnvironmentObject var messageService: MessageService
    
    var body: some View {
        VStack {
            // 聊天记录
            ScrollView {
                ForEach(messages, id: \.text) { message in
                    if isNewDay(message: message) {
                        Text(formatDate(message.date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    ChatBubble(text: message.text, isUser: message.isUser)
                }
            }
            .gesture(DragGesture().onChanged(handleDragGesture))
            
            
            
            HStack {
                // 文本输入框
                if isTextFieldVisible {
                    TextField("Enter message", text: $messageText, onCommit: sendMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                // 语音输入按钮
                Button(action: startVoiceInput) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .clipShape(Circle())
                }
            }
        }.onReceive(messageService.$responseMessage) { response in
            if let responseText = response {
                self.messages.append((text: "GPT: \(responseText)", isUser: false, date: Date()))
            }
        }
    }
    
    func handleDragGesture(_ gesture: DragGesture.Value) {
        print("Drag translation: \(gesture.translation)")
        let dragThreshold: CGFloat = -10 // 调整此值以改变灵敏度
        
        if gesture.translation.height < dragThreshold && gesture.translation.width.abs < dragThreshold.abs / 2 {
            print("Drag gesture activated")
            self.isTextFieldVisible = true
        }
    }
    
    func startVoiceInput() {
        // 语音输入逻辑
        print("hitting button")
    }
    
    func sendMessage() {
        // 发送消息
        messages.append((text: messageText, isUser: true, date: Date()))
        let prompt = messageText
        messageService.sendMessage(prompt)
        messageText = ""
    }
    
    func isNewDay(message: (text: String, isUser: Bool, date: Date)) -> Bool {
        // 逻辑来检查这是否是新的一天的第一条消息
        return true
    }
    
    func formatDate(_ date: Date) -> String {
        // 格式化日期
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct ChatBubble: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser {
                Spacer()
                Text(text)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            } else {
                Text(text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

extension CGFloat {
    var abs: CGFloat {
        return Swift.abs(self)
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView().environmentObject(MessageService())
    }
}
