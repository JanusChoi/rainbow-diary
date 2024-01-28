//
//  ListView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/4.
//

import SwiftUI

struct ListView: View {
    @Binding var conversations: [Conversation]
    @Binding var selectedConversationId: Conversation.ID?
    
    var store: ChatStore
    
    private var groupedConversations: [Date: [Conversation]] {
        groupConversationsByDate(conversations)
    }
    
    var body: some View {
        List {
            ForEach(groupedConversations.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(dateString(from: date))) {
                    ForEach(groupedConversations[date] ?? [], id: \.id) { conversation in
                        NavigationLink(value: conversation.id) {
                            Text(conversation.messages.last?.content ?? "New Session")
                                .lineLimit(2)
                        }
                    }
                    .onDelete(perform: deleteConversations)
                }
            }
        }
        .navigationTitle("Sessions")
    }
    
    
    // 辅助函数来格式化日期字符串
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func groupConversationsByDate(_ conversations: [Conversation]) -> [Date: [Conversation]] {
        let grouped = Dictionary(grouping: conversations) { (conversation) -> Date in
            // 这里假设 `createdAt` 是每个对话的日期。根据您的模型调整
            return Calendar.current.startOfDay(for: conversation.createdAt)
        }
        return grouped
    }
    
    private func deleteConversations(at offsets: IndexSet) {
        // 遍历 IndexSet 并删除对话
        for index in offsets {
            let conversationId = conversations[index].id
            store.deleteConversation(conversationId)
        }
    }
}
