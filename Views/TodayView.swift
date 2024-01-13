//
//  TodayView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/16.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject var store: ChatStore
    
    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider
    
    @State private var messageText: String = ""
    @State private var entries: [Entry] = []
    @State private var messages: [(text: String, isUser: Bool, date: Date)] = []
    @State private var isTextFieldVisible: Bool = true
    @State private var isEditorExpanded: Bool = false
    @EnvironmentObject var messageService: MessageService
    
    let dataService: DataStorageService = DataStorageService.shared // 获取 DataStorageService 实例
    
    public init(store: ChatStore) {
        self.store = store
    }
    
    var body: some View {
        NavigationSplitView {
            ListView(
                conversations: $store.conversations,
                selectedConversationId: Binding<Conversation.ID?>(
                    get: {
                        store.selectedConversationID
                    }, set: { newId in
                        store.selectConversation(newId)
                    })
            )
            .toolbar {
                ToolbarItem(
                    placement: .primaryAction
                ) {
                    Button(action: {
                        store.createConversation()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .clipShape(Circle())
                            .imageScale(.small)
                    }
                }
            }
        } detail: {
            if let conversation = store.selectedConversation {
                DetailView(
                    dataService: dataService, conversation: conversation,
                    error: store.conversationErrors[conversation.id],
                    sendMessage: { message, selectedModel in
                        Task {
                            await store.sendMessage(
                                Message(
                                    id: idProvider(),
                                    role: .user,
                                    content: message,
                                    createdAt: dateProvider()
                                ),
                                conversationId: conversation.id,
                                model: selectedModel
                            )
                        }
                    }
                )
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

extension CGFloat {
    var abs: CGFloat {
        return Swift.abs(self)
    }
}


//struct TodayView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodayView().environmentObject(MessageService())
//    }
//}
