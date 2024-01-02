//
//  Conversation.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/2.
//

import Foundation

struct Conversation {
    init(id: String, messages: [Message] = []) {
        self.id = id
        self.messages = messages
    }
    
    typealias ID = String
    
    let id: String
    var messages: [Message]
}

extension Conversation: Equatable, Identifiable {}
