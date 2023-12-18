//
//  StoryView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/16.
//

import SwiftUI

struct SummaryCard {
    var date: Date
    var keywords: [String]
    var image: UIImage
}

func generateSummaryCards() -> [SummaryCard] {
    // 实际应用中，这里应该是分析聊天记录并生成卡片数据的逻辑
    // 这里仅作为示例使用静态数据
    let sampleCard = SummaryCard(date: Date(), keywords: ["关键字1", "关键字2"], image: UIImage(systemName: "photo")!)
    return [sampleCard, sampleCard, sampleCard] // 示例数据
}

struct SummaryCardView: View {
    var card: SummaryCard

    var body: some View {
        GeometryReader { geometry in
            HStack {
                // 左侧文字部分
                VStack(alignment: .leading) {
                    Text("\(card.date, formatter: dateFormatter)")
                    ForEach(card.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption)
                    }
                }
                .frame(width: geometry.size.width / 2)

                // 分割线
                Divider()
                    .frame(height: geometry.size.height)

                // 右侧图片部分
                Image(uiImage: card.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width / 2)
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


struct StoryView: View {
    let cards = generateSummaryCards()

    var body: some View {
        ScrollView {
            VStack {
                ForEach(cards.indices, id: \.self) { index in
                    SummaryCardView(card: cards[index])
                }
            }
            .padding()
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}
