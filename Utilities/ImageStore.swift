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
    
    @Published var imageResults: [ImagesResult.URLResult] = []
    
    var dataService: DataStorageService
    
    public init(
        openAIClient: OpenAIProtocol,
        dataService: DataStorageService
    ) {
        self.openAIClient = openAIClient
        self.dataService = dataService
    }
    
    @MainActor
    func fetchImages(query: ImagesQuery) async {
        imageResults.removeAll()
        do {
            let response = try await openAIClient.images(query: query)
            imageResults = response.data
        } catch {
            // TODO: Better error handling
            print(error.localizedDescription)
        }
    }
    
    func generateSummaryCards(for daySummary: DaySummary) async {
        print("Entering generateSummaryCards")
        
        print("daySummary keywords: \(daySummary.keywords ?? "nil")")
        print("daySummary summaryText: \(daySummary.summaryText ?? "nil")")
        guard let keywords = daySummary.keywords?.components(separatedBy: ", "),
              let summaryText = daySummary.summaryText else {
            print("Required data is missing in daySummary")
            return
        }
        
        // 构建图片生成的 prompt
        let prompt = "请你扮演一个专业插画师，将以下文本生成配图，进行以下步骤：1.理解文本内容：仔细阅读提供的文本，确保对其内容和主题有深入的理解；2. 根据文本确定插图风格：根据文本内容和氛围，选择一个合适的插图风格；3. 生成比例为4:3的图片。文本：{\(summaryText)}"
        
        // 构建 ImagesQuery 实例
        let query = ImagesQuery(prompt: prompt, n: 1, size: "512x512", user: nil)
        
        // 调用 ImageStore 的 images 方法生成图片
        await fetchImages(query: query)
        
        // 假设 images 数组中的第一个元素是我们想要的图片
        if let firstImageResult = imageResults.first,
           let imageUrlString = firstImageResult.url, // 假设 URLResult 有一个 url 属性
           let imageUrl = URL(string: imageUrlString) {
            let imagePath = await dataService.saveImageToFileSystem(from: imageUrl)
            daySummary.imageURL = imageUrl.absoluteString
            daySummary.fileURL = imagePath
        }
    }
}
