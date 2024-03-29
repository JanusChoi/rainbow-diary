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
                selectedConversationId: $store.selectedConversationID,
                store: store
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
            .navigationDestination(for: String.self) { conversationId in
//                Text("Navigating to conversation with ID: \(conversationId)")
                detailViewFor(conversationId: conversationId)
            }
        } detail: {
            if let conversationId = store.selectedConversationID,
               let conversation = store.conversations.first(where: { $0.id == conversationId }) {
//                Text("DetailView for selected conversation with ID: \(conversation.id)")
                detailViewFor(conversationId: conversation.id)
            }
        }
        .onAppear {
            store.loadConversationsFromEntries()
        }
    }
    
    @ViewBuilder
    private func detailViewFor(conversationId: String) -> some View {
        // 使用集合来查找对应的 Conversation
//        Text("Constructing DetailView for conversation with ID: \(conversationId)")
        if let conversation = store.conversations.first(where: { $0.id == conversationId }) {
            DetailView(
                dataService: dataService,
                store: store, conversation: conversation,
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
        } else {
            Text("Conversation not found")
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
