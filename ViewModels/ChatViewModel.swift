//
//  ChatViewModel.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/18.
//

import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []

    func loadMessages() {
        // 加载消息
    }

    func saveMessage(_ message: ChatMessage) {
        // 保存消息
        messages.append(message)
    }

    func analyzeDataForInsights() -> InsightsData {
        // 示例心情趋势数据
        let moodTrend = MoodTrend(dataPoints: [3.5, 4.0, 2.5, 3.0, 4.5])

        // 示例词频统计数据
        let wordFrequencies = [
            WordFrequency(word: "快乐", frequency: 5),
            WordFrequency(word: "悲伤", frequency: 2),
            WordFrequency(word: "兴奋", frequency: 4)
        ]

        // 示例大五人格特质数据
        let personalityTraits = PersonalityTraits(
            openness: 0.8,
            conscientiousness: 0.6,
            extraversion: 0.7,
            agreeableness: 0.75,
            neuroticism: 0.5
        )

        // 构造并返回 InsightsData
        return InsightsData(
            moodTrend: moodTrend,
            wordFrequencies: wordFrequencies,
            personalityTraits: personalityTraits
        )
    }
}
