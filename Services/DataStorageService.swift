//
//  DataStorageService.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/18.
//

import CoreData
import SwiftUI

class DataStorageService {
    
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
    
    // 创建一个新的日记条目
    func createEntry(text: String, createdAt: Date, user: DiaryUser, mood: Mood? = nil) -> Entry {
        let context = persistentContainer.viewContext
        let entry = Entry(context: context)
        entry.id = UUID()
        entry.text = text
        entry.createdAt = createdAt
        entry.user = user
        entry.mood = mood
        saveContext()
        return entry
    }
    
    // 根据ID获取日记条目
    func fetchEntry(byId id: UUID) -> [Entry]? {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request)
    }
    
    // 根据日期获取日记条目
    func fetchEntriesForToday(user: DiaryUser) -> [Entry] {
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!

        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()

        // Create a predicate to filter entries by today's date and user ID
        let datePredicate = NSPredicate(format: "(createdAt >= %@) AND (createdAt < %@)", todayStart as NSDate, todayEnd as NSDate)
        let userPredicate = NSPredicate(format: "user == %@", user)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, userPredicate])

        return (try? context.fetch(request)) ?? []
    }

    
    // 更新日记条目
    func updateEntry(entry: Entry, withNewText text: String) {
        entry.text = text
        saveContext()
    }
    
    // 删除日记条目
    func deleteEntry(_ entry: Entry) {
        let context = persistentContainer.viewContext
        context.delete(entry)
        saveContext()
    }
    
    // MARK: - DaySummary Entity
    // 实现DaySummary实体的CRUD方法...
    
    // MARK: - Mood Entity
    // 实现Mood实体的CRUD方法...
    
    // MARK: - MoodSummary Entity
    // 实现MoodSummary实体的CRUD方法...
    
    // MARK: - Personality Entity
    // 实现Personality实体的CRUD方法...
    
    // MARK: - GeneratedImage Entity
    // 实现GeneratedImage实体的CRUD方法...
}
