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
    
    var body: some View {
        List(
            $conversations,
            editActions: [.delete],
            selection: $selectedConversationId
        ) { $conversation in
            Text(
                conversation.messages.last?.content ?? "New Session"
            )
            .lineLimit(2)
        }
        .navigationTitle("Sessions")
    }
}
