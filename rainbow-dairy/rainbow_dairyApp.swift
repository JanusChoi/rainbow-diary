//
//  rainbow_dairyApp.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/12.
//

import SwiftUI

@main
struct rainbow_dairyApp: App {
    @State private var hasCompletedOnboarding: Bool = UserDefaults.standard.string(forKey: "diaryUserId") != nil
    // 检查用户是否已经完成了引导流程
//    var hasCompletedOnboarding: Bool {
//        UserDefaults.standard.string(forKey: "diaryUserId") != nil
//    }
    
    var messageService = MessageService()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                // 如果用户已完成引导，显示主内容视图
                ContentView()
                    .environmentObject(messageService)
            } else {
                // 如果用户未完成引导，显示引导视图
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding, dataService: DataStorageService.shared)
                    .environmentObject(messageService)
            }
        }
    }
}
//struct rainbow_dairyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(MessageService())
//        }
//    }
//}
