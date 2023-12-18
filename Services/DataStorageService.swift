//
//  DataStorageService.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/18.
//

import CoreData
import SwiftUI

class DataStorageService {
    // 引用持久化容器
    private let container: NSPersistentContainer

    // 初始化
    init() {
        container = NSPersistentContainer(name: "YourModelName")
        container.loadPersistentStores { _, error in
            if let error = error {
                // 处理加载错误
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }

    // 保存聊天消息
    func saveMessage(_ message: ChatMessage) {
        let cdMessage = ChatMessage(context: container.viewContext)
        cdMessage.text = message.text
        cdMessage.date = message.date
        cdMessage.isUser = message.isUser
        cdMessage.mood = message.mood // 假设 mood 是枚举类型

        do {
            try container.viewContext.save()
        } catch {
            print("Failed to save message: \(error.localizedDescription)")
        }
    }

    // 读取聊天消息
    func fetchMessages() -> [ChatMessage] {
        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()

        do {
            let cdMessages = try container.viewContext.fetch(request)
            return cdMessages
        } catch {
            print("Failed to fetch messages: \(error.localizedDescription)")
            return []
        }
    }

    // 其他数据操作...
}
