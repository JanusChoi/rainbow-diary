//
//  ChatView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/4.
//

import Combine
import SwiftUI

public struct ChatView: View {
    @ObservedObject var store: ChatStore
    
    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider

    public init(store: ChatStore) {
        self.store = store
    }
    
    public var body: some View {
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
                    placement: .navigationBarTrailing
                ) {
                    Button(action: {
                        store.createConversation()
                    }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        } detail: {
            if let conversation = store.selectedConversation {
                DetailView(
                    conversation: conversation,
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
}
