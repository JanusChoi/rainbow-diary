import SwiftUI

struct ContentView: View {
    @State private var messageText: String = ""
    @State private var messages: [(text: String, isUser: Bool)] = []
    @State private var isTextFieldVisible: Bool = false

    var body: some View {
        VStack {
            // 聊天记录
            ScrollView {
                ForEach(messages, id: \.text) { message in
                    ChatBubble(text: message.text, isUser: message.isUser)
                }
            }
            .gesture(DragGesture().onChanged(handleDragGesture))

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
            .padding()
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
        messages.append((text: messageText, isUser: true))
        messageText = ""

        // 模拟App回复
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append((text: "App Reply: \(messageText)", isUser: false))
        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
