//
//  MessageService.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/14.
//

import Foundation
import OpenAI

class MessageService: MessageSender, ObservableObject {
    @Published var responseMessage: String? = nil
    //    private let openAI = OpenAI(apiToken: "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")
    
    func sendMessage(_ message: String) {
        guard let openaiKey = getOpenAIKey() else {
            print("OpenAI Key not found")
            return
        }
        
        print("Sending message: \(message) with OpenAI Key")
        
        let openAI = OpenAI(apiToken: openaiKey)
        // 创建 ChatQuery 实例
        let chatQuery = ChatQuery(model: "gpt-3.5-turbo-0613", messages: [.init(role: .user, content: message)])
        
        // 发送请求
        openAI.chats(query: chatQuery) { result in
            switch result {
            case .success(let completionResponse):
                DispatchQueue.main.async {
                    if let firstChoice = completionResponse.choices.first {
                        self.responseMessage = firstChoice.message.content
                    }
                    print("GPT: \(completionResponse.choices)")
                }
            case .failure(let error):
                print("Error calling OpenAI: \(error.localizedDescription)")
            }
        }
    }
    
    func getOpenAIKey() -> String? {
        UserDefaults.standard.string(forKey: "openaiKey")
    }
}
