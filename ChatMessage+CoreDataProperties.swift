//
//  ChatMessage+CoreDataProperties.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/18.
//
//

import Foundation
import CoreData


extension ChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatMessage> {
        return NSFetchRequest<ChatMessage>(entityName: "ChatMessage")
    }

    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var isUser: Bool
    @NSManaged public var mood: String?

}

extension ChatMessage : Identifiable {

}
