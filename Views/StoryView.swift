//
//  StoryView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/16.
//

import SwiftUI
import OpenAI

struct SummaryCard {
    var date: Date
    var keywords: [String]
    var image: UIImage
}

struct StoryView: View {
    @State private var cards: [SummaryCard] = []
    @State private var isLoading = true
    @State private var selectedChatModel: Model = .gpt3_5Turbo_16k_0613
    
    // 这里注入所需的服务
    @ObservedObject var chatStore: ChatStore
    @ObservedObject var imageStore: ImageStore
    let dataService: DataStorageService = DataStorageService.shared
    
    var body: some View {
//        NavigationView {
            ScrollView {
                VStack {
                    if isLoading {
                        ProgressView()
                    } else if cards.isEmpty {
                        // 当没有数据时显示的内容
                        Text("No summaries currently. Tap 'Generate' to create summaries.")
                            .padding()
                            .foregroundColor(.gray)
                    } else {
                        ForEach(cards.indices, id: \.self) { index in
                            SummaryCardView(card: cards[index])
                        }
                    }
                }
                .padding()
                
            }
//        }
        .navigationTitle("Story")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: generateSummary) {
                    Text("Generate")
                }
            }
        }
        .onAppear {
            print("Load StoryView")
            loadData()
        }
    }
    
    private func loadData() {
        // 异步加载 DaySummary 数据并生成卡片
        Task {
            await loadSummaryCards()
            isLoading = false
        }
        // 添加模拟数据
//        let mockImage = UIImage(systemName: "photo") ?? UIImage()
//        let mockCards = [
//            SummaryCard(date: Date(), keywords: ["Keyword1", "Keyword2"], image: mockImage),
//            SummaryCard(date: Date().addingTimeInterval(-86400), keywords: ["Keyword3", "Keyword4"], image: mockImage),
//            SummaryCard(date: Date().addingTimeInterval(-172800), keywords: ["Keyword5", "Keyword6"], image: mockImage)
//        ]
        
        // 将模拟数据赋值给 cards
//        cards = mockCards
//        isLoading = false
    }
    
    private func generateSummary() {
        print("Generate button tapped")
        isLoading = true
        Task {
            await chatStore.generateDaySummary(model:selectedChatModel)
            
            let daySummaries = dataService.fetchDaySummaries()
            
            if let firstDaySummary = daySummaries.first {
                await imageStore.generateSummaryCards(for: firstDaySummary)
            }
            await loadSummaryCards()
            isLoading = false
        }
    }
    
    private func loadSummaryCards() async {
        print("getting Summary Cards")
        // 从 DataStorageService 加载 DaySummary 实体
        let daySummaries = dataService.fetchDaySummaries()
        
        // 根据 DaySummary 实体生成 SummaryCard
        cards = daySummaries.map { daySummary in
            let image = loadImage(from: daySummary.fileURL ?? "")
            return SummaryCard(
                date: daySummary.createdAt ?? Date(),
                keywords: daySummary.keywords?.components(separatedBy: ", ") ?? [],
                image: image)
        }
        print("got Summary Cards\(cards)")
    }
    
    private func loadImage(from imagePath: String) -> UIImage {
        // 检查路径是否有效
        guard !imagePath.isEmpty else {
            return UIImage(systemName: "photo")! // 或者返回一个默认图片
        }
        
        let fileURL = URL(fileURLWithPath: imagePath)
        
        // 从文件系统加载图片
        do {
            let data = try Data(contentsOf: fileURL)
            if let image = UIImage(data: data) {
                return image
            }
        } catch {
            print("Error loading image from path: \(imagePath), \(error)")
        }
        
        return UIImage(systemName: "photo")! // 示例返回
    }
}

struct SummaryCardView: View {
    var card: SummaryCard
    
    var body: some View {
//        GeometryReader { geometry in
        VStack {
            HStack {
                // 左侧文字部分
                VStack(alignment: .leading) {
                    Text("\(card.date, formatter: dateFormatter)")
                    ForEach(card.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption)
                    }
                }
//                .frame(width: geometry.size.width / 2)
                
                // 分割线
                Divider()
//                    .frame(height: geometry.size.height)
                
                // 右侧图片部分
                Image(uiImage: card.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                    .frame(width: geometry.size.width / 2)
            }
        }
        .frame(height: 200) // 设置卡片的高度
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
