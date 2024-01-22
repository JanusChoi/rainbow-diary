//
//  ImageStore.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/3.
//

import Foundation
import OpenAI

public final class ImageStore: ObservableObject {
    public var openAIClient: OpenAIProtocol
    
    @Published var images: [ImagesResult.URLResult] = []
    
    var dataService: DataStorageService
    
    public init(
        openAIClient: OpenAIProtocol,
        dataService: DataStorageService
    ) {
        self.openAIClient = openAIClient
        self.dataService = dataService
    }
    
    @MainActor
    func images(query: ImagesQuery) async {
        images.removeAll()
        do {
            let response = try await openAIClient.images(query: query)
            images = response.data
        } catch {
            // TODO: Better error handling
            print(error.localizedDescription)
        }
    }
    
    func generateSummaryCards(for daySummary: DaySummary) async {
        guard let keywords = daySummary.keywords?.components(separatedBy: ", "),
              let summaryText = daySummary.summaryText else { return }
        
        // 构建图片生成的 prompt
        let prompt = "\(summaryText)\n关键词: \(keywords.joined(separator: ", "))"
        
        // 构建 ImagesQuery 实例
        let query = ImagesQuery(prompt: prompt, n: 1, size: "1024x1024", user: nil)
        
        // 调用 ImageStore 的 images 方法生成图片
        await images(query: query)
        
        // 假设 images 数组中的第一个元素是我们想要的图片
        if let firstImageResult = images.first,
           let imageUrlString = firstImageResult.url, // 假设 URLResult 有一个 url 属性
           let imageUrl = URL(string: imageUrlString) {
            let imagePath = await dataService.saveImageToFileSystem(from: imageUrl)
            daySummary.image = imagePath
        }
    }
}
