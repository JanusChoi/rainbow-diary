//
//  Conversation.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/2.
//

import Foundation

struct Conversation {
    let id: String
    var messages: [Message]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String, messages: [Message] = [], createdAt: Date=Date(), updatedAt: Date=Date()) {
        self.id = id
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    typealias ID = String
    
    
}

extension Conversation: Equatable, Identifiable {}
