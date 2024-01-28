//
//  ChatStore.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/2.
//

import Foundation
import Combine
import OpenAI

public final class ChatStore: ObservableObject {
    public var openAIClient: OpenAIProtocol
    let idProvider: () -> String
    
    @Published var conversations: [Conversation] = []
    @Published var conversationErrors: [Conversation.ID: Error] = [:]
    @Published var selectedConversationID: Conversation.ID?
    
    var dataService: DataStorageService
    
    var selectedConversation: Conversation? {
        selectedConversationID.flatMap { id in
            conversations.first { $0.id == id }
        }
    }
    
    var selectedConversationPublisher: AnyPublisher<Conversation?, Never> {
        $selectedConversationID.receive(on: RunLoop.main).map { id in
            self.conversations.first(where: { $0.id == id })
        }
        .eraseToAnyPublisher()
    }
    
    public init(
        openAIClient: OpenAIProtocol,
        idProvider: @escaping () -> String,
        dataService: DataStorageService
    ) {
        self.openAIClient = openAIClient
        self.idProvider = idProvider
        self.dataService = dataService
    }
    
    // MARK: - Events
    func createConversation() {
        let conversation = Conversation(id: idProvider(), messages: [], createdAt: Date(), updatedAt: Date())
        conversations.append(conversation)
        print("Created new conversation with ID: \(conversation.id)")
        selectedConversationID = conversation.id // 设置新会话为当前选中的会话
        
        dataService.createOrUpdateEntry(from: conversation)
    }
    
    func updateConversation(id: Conversation.ID, with newMessage: Message) {
        // 查找特定 ID 的对话
        if let index = conversations.firstIndex(where: { $0.id == id }) {
            // 更新对话中的消息和更新时间
            conversations[index].messages.append(newMessage)
            conversations[index].updatedAt = Date()
            
            if dataService.fetchEntry(byId: id) != nil {
                dataService.createOrUpdateEntry(from: conversations[index], isUpdate: true)
            }
        }
    }
    
    func selectConversation(_ conversationId: Conversation.ID?) {
        print("ChatStore: Selecting Conversation with ID \(String(describing: conversationId))")
        selectedConversationID = conversationId
        print("Selected conversation with ID: \(String(describing: conversationId))")
    }
    
    func deleteConversation(_ conversationId: Conversation.ID) {
        conversations.removeAll(where: { $0.id == conversationId })
        
        if let entry = dataService.fetchEntry(byId: conversationId) {
            dataService.deleteEntry(entry)
        }
    }
    
    func loadConversationsFromEntries() {
        let entries = dataService.fetchAllEntries()
        // 设置默认日期
        let defaultDate = DateFormatter().date(from: "2023-03-01") ?? Date()
        // 将每个 Entry 转换为 Conversation
        self.conversations = entries.map { entry in
            // 转换消息字符串为 Message 数组
//            let messages = (entry.messages as? Set<EntryMessage>)?.map { entryMessage in
//                Message(
//                    id: entryMessage.id ?? UUID().uuidString,
//                    role: Chat.Role(rawValue: entryMessage.role ?? "") ?? .user,
//                    content: entryMessage.content ?? "",
//                    createdAt: entryMessage.createdAt ?? defaultDate
//                )
//            } ?? []
//            // 假设 Entry 包含必要的信息来构建 Conversation
            let messages = (entry.messages as? Set<EntryMessage>)?
                .sorted(by: { $0.sequence < $1.sequence }) // 根据 sequence 排序
                .map { entryMessage in
                    Message(
                        id: entryMessage.id ?? UUID().uuidString,
                        role: Chat.Role(rawValue: entryMessage.role ?? "") ?? .user,
                        content: entryMessage.content ?? "",
                        createdAt: entryMessage.createdAt ?? Date()
                    )
                } ?? []
            
            return Conversation(
                id: entry.id?.uuidString ?? UUID().uuidString, // 转换 UUID 为 String
                messages: messages,
                createdAt: entry.createdAt ?? defaultDate,
                updatedAt: entry.updatedAt ?? defaultDate
            )
        }
    }
    
    // MARK: - Handle Events between Conversations and Entry
    
//    func saveConversationToEntry(_ conversation: Conversation) {
//        if let existingEntry = dataService.fetchEntry(byId: conversation.id) {
//            dataService.updateEntry(existingEntry, with: conversation)
//        } else {
//            dataService.createEntry(from: conversation)
//        }
//    }
    
    // MARK: - Handle Summaries
    // MARK: - DaySummary Entity
    // 实现DaySummary实体的CRUD方法...
    func generateDaySummary(model: Model) async {
        print("Entering generateDaySummary")
        let entries = dataService.fetchAllEntries(for: Date())
        
        // 将所有条目的内容合并为一个长字符串
//        let allEntriesContent = entries.map { entry in
//            let messages = (entry.messages as? Set<EntryMessage>)?.map {
//                entryMessage in entryMessage.content
//            }
//        }
        let allEntriesContent = entries.flatMap { entry -> [String] in
                guard let entryMessages = entry.messages as? Set<EntryMessage> else {
                    return []
                }
                return entryMessages.compactMap { $0.content }
            }.joined(separator: "\n")
        
        // 构造 prompt，包括条目内容和请求关键词的指示
        let prompt_keyword = "基于以下对话内容，请归纳总结提取3个关键词:\n\(allEntriesContent)，请注意只输出json格式如下[\"关键词1\",\"关键词2\",\"关键词3\"]"
        
        let response_keyword = await sendPromptAndGetResponse(prompt: prompt_keyword,  model: model)
        
        // 解析 response 来获取关键词
        guard let keywords = parseKeywords(from: response_keyword) else {
            print("Error: Unable to parse keywords")
            return
        }
        
        // 构造 prompt，包括条目内容和请求关键词的指示
        let prompt_summary = "基于以下对话内容，请归纳总结一段简洁的文字:\n\(allEntriesContent)"
        
        let response_summary = await sendPromptAndGetResponse(prompt: prompt_summary, model: model)
        
        // 解析 response 来获取关键词
        let summary = response_summary
        
        // 将关键词保存到 DaySummary 实体中
        dataService.saveKeywordsToDaySummary(keywords, summary: summary)
    }
    
    func parseKeywords(from response: String) -> [String]? {
        guard let data = response.data(using: .utf8),
              let keywords = try? JSONDecoder().decode([String].self, from: data) else {
            return nil
        }
        return keywords
    }
    
    // MARK: - Update OpenAI Client
    func updateClient(_ newClient: OpenAIProtocol) {
        self.openAIClient = newClient
    }
    
    @MainActor
    func sendMessage(
        _ message: Message,
        conversationId: Conversation.ID,
        model: Model
    ) async {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        conversations[conversationIndex].messages.append(message)
        
        await completeChat(
            conversationId: conversationId,
            model: model
        )
    }
    
    @MainActor
    func completeChat(
        conversationId: Conversation.ID,
        model: Model
    ) async {
        guard let conversation = conversations.first(where: { $0.id == conversationId }) else {
            return
        }
        
        conversationErrors[conversationId] = nil
        
        do {
            guard let conversationIndex = conversations.firstIndex(where: { $0.id == conversationId }) else {
                return
            }
            
            let weatherFunction = ChatFunctionDeclaration(
                name: "getWeatherData",
                description: "Get the current weather in a given location",
                parameters: .init(
                    type: .object,
                    properties: [
                        "location": .init(type: .string, description: "The city and state, e.g. San Francisco, CA")
                    ],
                    required: ["location"]
                )
            )
            
            let moodFunction = ChatFunctionDeclaration(
                name: "getMoodData",
                description: "Get the current mood base on given context",
                parameters: .init(
                    type: .object,
                    properties: [
                        "context": .init(type: .string, description: "Today I am having a good day, e.g. Happy")
                    ],
                    required: ["context"]
                )
            )
            
            _ = [weatherFunction, moodFunction]
            
            let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = openAIClient.chatsStream(
                query: ChatQuery(
                    model: model,
                    messages: conversation.messages.map { message in
                        Chat(role: message.role, content: message.content)
                    }//,
//                    functions: functions
                )
            )
            
            var functionCallName = ""
            var functionCallArguments = ""
            for try await partialChatResult in chatsStream {
//                print("Received raw data: \(partialChatResult)")
                for choice in partialChatResult.choices {
                    let existingMessages = conversations[conversationIndex].messages
                    // Function calls are also streamed, so we need to accumulate.
                    if let functionCallDelta = choice.delta.functionCall {
                        if let nameDelta = functionCallDelta.name {
                            functionCallName += nameDelta
                        }
                        if let argumentsDelta = functionCallDelta.arguments {
                            functionCallArguments += argumentsDelta
                        }
                    }
                    var messageText = choice.delta.content ?? ""
                    if let finishReason = choice.finishReason,
                       finishReason == "function_call" {
                        messageText += "Function call: name=\(functionCallName) arguments=\(functionCallArguments)"
                    }
//                    print("completeChat Receiving \(messageText)")
                    let message = Message(
                        id: partialChatResult.id,
                        role: choice.delta.role ?? .assistant,
                        content: messageText,
                        createdAt: Date(timeIntervalSince1970: TimeInterval(partialChatResult.created))
                    )
                    if let existingMessageIndex = existingMessages.firstIndex(where: { $0.id == partialChatResult.id }) {
                        // Meld into previous message
                        let previousMessage = existingMessages[existingMessageIndex]
                        let combinedMessage = Message(
                            id: message.id, // id stays the same for different deltas
                            role: message.role,
                            content: previousMessage.content + message.content,
                            createdAt: message.createdAt
                        )
                        conversations[conversationIndex].messages[existingMessageIndex] = combinedMessage
                    } else {
                        conversations[conversationIndex].messages.append(message)
                    }
                }
            }
        } catch DecodingError.dataCorrupted(let context) {
            print("JSON Decoding Error: \(context.debugDescription)")
            // 可以添加更多处理逻辑
        } catch {
            print("Error's occur: \(error)")
            conversationErrors[conversationId] = error
        }
    }
    
    @MainActor
    func sendPromptAndGetResponse(
        prompt: String,
        model: Model
    ) async -> String {
        // 构建请求所需的 ChatQuery
        let query = ChatQuery(
            model: model,
            messages: [Chat(role: .user, content: prompt)] // 只包含一个用户消息
        )
        
        // 发起请求并处理响应
        do {
            let result = try await openAIClient.chats(query: query)
            print("Received result: \(result)") // 打印收到的响应内容
            let responseContent = result.choices.first?.message.content
            print("Getting content: \(String(describing: responseContent))")
            return responseContent ?? ""
        } catch {
            print("Error in sending prompt and getting response: \(error)")
        }
        
        return "" // 如果出错或没有收到响应，则返回空字符串
    }
}
