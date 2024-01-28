//
//  DataStorageService.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/18.
//

import CoreData
import SwiftUI
import OpenAI

public class DataStorageService {
    
    // MARK: - Core Data stack
    
    // 创建一个静态共享实例，使得这个服务可以在应用中被全局访问。
    static let shared = DataStorageService()
    
    // 私有初始化方法，防止外部创建多个实例。
    private init() {}
    
    // 懒加载持久化容器，用于设置和管理CoreData堆栈。
    lazy var persistentContainer: NSPersistentContainer = {
        // 创建一个与模型文件同名的持久化容器。
        let container = NSPersistentContainer(name: "DiaryModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // 如果加载存储时出现错误，程序将崩溃并打印错误信息。
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // 返回配置好的容器。
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    // 保存上下文的方法，用于将更改保存到持久化存储。
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                // 尝试保存上下文。
                try context.save()
            } catch {
                // 如果保存失败，程序将崩溃并打印错误信息。
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - User Entity
    
    // 创建一个新用户的方法。
    func createUser(username: String, createdAt: Date, openaiKey: String) -> DiaryUser {
        let context = persistentContainer.viewContext
        // 创建一个新的User实体。
        let user = DiaryUser(context: context)
        user.id = UUID()
        user.username = username
        user.openaiKey = openaiKey
        user.createdAt = createdAt
        saveContext()
        return user
    }
    
    // 根据ID获取用户的方法。
    func fetchUser(byId id: UUID) -> DiaryUser? {
        let context = persistentContainer.viewContext
        // 创建一个请求来获取User实体。
        let request: NSFetchRequest<DiaryUser> = DiaryUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        // 尝试执行请求并返回第一个匹配的用户，如果没有则返回nil。
        return try? context.fetch(request).first
    }
    
    // 更新用户信息的方法。
    func updateUser(user: DiaryUser, withNewUsername username: String) {
        user.username = username // 更新用户名。
        saveContext() // 保存更改到CoreData。
    }
    
    // 删除用户的方法。
    func deleteUser(_ user: DiaryUser) {
        let context = persistentContainer.viewContext
        context.delete(user) // 从上下文中删除用户。
        saveContext() // 保存更改到CoreData。
    }
    
    // 获取当前用户
    func getCurrentUser() -> DiaryUser? {
        guard let userIdString = UserDefaults.standard.string(forKey: "diaryUserId"),
              let userId = UUID(uuidString: userIdString) else {
            return nil
        }
        return fetchUser(byId: userId)
    }
    
    // MARK: - Entry Entity
    
    func fetchAllEntries(for date: Date? = nil) -> [Entry] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        if let date = date {
            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            let datePredicate = NSPredicate(format: "(createdAt >= %@) AND (createdAt < %@)", startOfDay as NSDate, endOfDay as NSDate)
            request.predicate = datePredicate
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }
    
    // 创建一个新的日记条目
//    func createEntry(from conversation: Conversation) {
//        let context = persistentContainer.viewContext
//        let entry = Entry(context: context)
//        entry.id = UUID()
//        entry.text = conversation.messages.map { $0.content }.joined(separator: "\n")
//        entry.createdAt = conversation.createdAt
//        entry.updatedAt = conversation.updatedAt
//        
//        saveContext()
//    }
    
    // 更新日记条目
//    func updateEntry(_ entry: Entry, with conversation: Conversation) {
//        entry.text = conversation.messages.map { $0.content }.joined(separator: "\n")
//        entry.updatedAt = conversation.updatedAt
//        saveContext()
//    }
    
    // 删除日记条目
    func deleteEntry(_ entry: Entry) {
        let context = persistentContainer.viewContext
        context.delete(entry)
        saveContext()
    }
    
    // 对话的创建与更新
    func createOrUpdateEntry(from conversation: Conversation, isUpdate: Bool = false) {
        let context = persistentContainer.viewContext
        let entry = isUpdate ? fetchEntry(byId: conversation.id) ?? Entry(context: context) : Entry(context: context)

        entry.id = UUID(uuidString: conversation.id) ?? UUID()
        entry.createdAt = conversation.createdAt
        entry.updatedAt = conversation.updatedAt
        
        // 清除旧的消息（如果是更新操作）
        if isUpdate, let oldMessages = entry.messages as? Set<EntryMessage> {
            for message in oldMessages {
                context.delete(message)
//                entry.addToMessages(message)
            }
        }
        
        // 更新或创建新的 EntryMessage 实例
        let newMessages = conversation.messages.enumerated().map { (index, message) in
            let entryMessage = EntryMessage(context: context)
            entryMessage.id = message.id
            entryMessage.role = message.role.rawValue
            entryMessage.content = message.content
            entryMessage.createdAt = message.createdAt
            entryMessage.sequence = Int16(index)
            return entryMessage
        }
        
        // 添加新的消息到 Entry
        entry.addToMessages(NSSet(array: newMessages))
        
        saveContext()
    }

    
    // 根据ID获取日记条目
    func fetchEntry(byId id: String) -> Entry? {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
    
    // 根据日期获取日记条目
    func fetchEntriesForToday() -> [Entry] {
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
        
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        // Create a predicate to filter entries by today's date and user ID
        let datePredicate = NSPredicate(format: "(createdAt >= %@) AND (createdAt < %@)", todayStart as NSDate, todayEnd as NSDate)
//        let userPredicate = NSPredicate(format: "user == %@", user)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - DaySummary Entity
    func saveKeywordsToDaySummary(_ keywords: [String], summary: String) {
        let context = persistentContainer.viewContext
        let daySummary = DaySummary(context: context)
        daySummary.id = UUID()
        daySummary.createdAt = Date()
        daySummary.keywords = keywords.joined(separator: ", ")
        daySummary.summaryText = summary
        
        do {
            try context.save()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func saveImageToFileSystem(from imageUrl: URL) async -> String {
        // 使用 URLSession 下载图片
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            if let image = UIImage(data: data) {
                // 获取沙盒目录
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileName = UUID().uuidString + ".jpg" // 创建一个唯一的文件名
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                // 将图片数据保存到文件
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    try imageData.write(to: fileURL)
                    return fileURL.path // 返回文件路径
                }
            }
        } catch {
            print("Error saving image to file system: \(error)")
        }
        return "" // 错误情况下返回空字符串或适当的错误处理
    }
    
    func fetchDaySummaries() -> [DaySummary] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<DaySummary> = DaySummary.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching day summaries: \(error)")
            return []
        }
        
    }
    
    // MARK: - MoodSummary Entity
    // 实现MoodSummary实体的CRUD方法...
    
    // MARK: - Personality Entity
    // 实现Personality实体的CRUD方法...
    
    // MARK: - GeneratedImage Entity
    // 实现GeneratedImage实体的CRUD方法...
}

class RoleValueTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let role = value as? Chat.Role else { return nil }
        return role.rawValue
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let roleValue = value as? String else { return nil }
        return Chat.Role(rawValue: roleValue)
    }
}
