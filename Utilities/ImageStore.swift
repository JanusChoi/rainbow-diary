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
    
    public init(
        openAIClient: OpenAIProtocol
    ) {
        self.openAIClient = openAIClient
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
}
