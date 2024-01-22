//
//  rainbow_dairyApp.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/12.
//

import SwiftUI
import OpenAI
import Speech

@main
struct rainbow_dairyApp: App {
    @StateObject var chatStore: ChatStore
    @State private var hasCompletedOnboarding: Bool = UserDefaults.standard.string(forKey: "diaryUserId") != nil
    @State private var hasInputKey: Bool = UserDefaults.standard.string(forKey: "apiKey") != nil
    @State var apiKey = UserDefaults.standard.string(forKey: "apiKey")
    
    @Environment(\.idProviderValue) var idProvider
    @Environment(\.dateProviderValue) var dateProvider

    var messageService = MessageService()
    
    init() {
        let apiKeyUnwrapped = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        print("Check apiKey:", apiKeyUnwrapped)
        let client = OpenAI(apiToken: apiKeyUnwrapped)
        let dataServiceInstance = DataStorageService.shared
        _chatStore = StateObject(
            wrappedValue: ChatStore(
                openAIClient: client,
                idProvider: { UUID().uuidString },
                dataService: dataServiceInstance
            )
        )
        requestSpeechAuthorization()
        // 注册转换器
        ValueTransformer.setValueTransformer(RoleValueTransformer(), forName: NSValueTransformerName("Chat.Role"))
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding && hasInputKey {
                // 如果用户已完成引导，显示主内容视图
                ContentView(chatStore: chatStore)
                    .environmentObject(messageService)
            } else {
                // 如果用户未完成引导，显示引导视图
                OnboardingView(chatStore: chatStore, hasCompletedOnboarding: $hasCompletedOnboarding, dataService: DataStorageService.shared)
                    .environmentObject(messageService)
            }
        }
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Main thread handle UI
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    // auth confirmed
                    break
                case .denied, .restricted, .notDetermined:
                    // auth not confirmed
                    break
                @unknown default:
                    break
                }
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
