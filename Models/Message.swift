//
//  Message.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/2.
//

import Foundation
import OpenAI

struct Message {
    var id: String
    var role: Chat.Role
    var content: String
    var createdAt: Date
}

extension Message: Equatable, Codable, Hashable, Identifiable {}
