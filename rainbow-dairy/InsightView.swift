//
//  InsightView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/16.
//

import SwiftUI
import SwiftUICharts // 引入图表库

struct InsightView: View {
    var body: some View {
        ScrollView {
            VStack {
                TextCardView()
                MoodTrendCardView()
                WordFrequencyCardView()
                PersonalityTraitCardView()
            }
            .padding()
        }
    }
}

struct TextCardView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            Text("已记录 30 天                                                                        ")
            Text("共收集 120 条心情或灵感")
            Text("累计写下 10000 字")
            Text("珍藏了 50 条图片回忆")
        }
        .background(Color.white)
        .padding(.all, 10.0)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxWidth: .infinity) // 使用最大宽度
    }
}

struct MoodTrendCardView: View {
    var body: some View {
        LineView(data: [8, 23, 54, 32, 12, 37, 7], title: "心情趋势")
            .padding()
            .frame(height: 400)
    }
}


struct WordFrequencyCardView: View {
    var body: some View {
        BarChartView(data: ChartData(values: [("关键词1", 6), ("关键词2", 9), ("关键词3", 7)]), title: "词频统计")
            .frame(maxWidth: .infinity) // 使用最大宽度
            .frame(height: 300) // 设置固定高度
    }
}

struct PersonalityTraitCardView: View {
    var body: some View {
        VStack {
            BarChartView(data: ChartData(values: [
                ("外向", 70),
                ("宜人", 80),
                ("尽责", 60),
                ("情绪稳定", 85),
                ("开放性", 90)
            ]), title: "大五人格分析")
        }
        .padding()
        .frame(width: .infinity)
    }
}


struct InsightView_Previews: PreviewProvider {
    static var previews: some View {
        InsightView()
    }
}
