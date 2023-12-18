//
//  InsightData.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/18.
//

import Foundation

struct InsightsData {
    var moodTrend: MoodTrend
    var wordFrequencies: [WordFrequency]
    var personalityTraits: PersonalityTraits
}

struct MoodTrend {
    var dataPoints: [Double] // 表示心情的数值，例如每天的心情评分
}

struct WordFrequency {
    var word: String
    var frequency: Int
}

struct PersonalityTraits {
    var openness: Double
    var conscientiousness: Double
    var extraversion: Double
    var agreeableness: Double
    var neuroticism: Double
}
