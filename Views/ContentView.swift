import SwiftUI

struct ContentView: View {
    @State private var messageText: String = ""
    @State private var messages: [(text: String, isUser: Bool, date: Date)] = []
    @State private var isTextFieldVisible: Bool = true
    
    var messageService = MessageService()
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏视图
            HStack {
                TabView {
                    TodayView()
                        .tabItem {
                            Label("今天", systemImage: "calendar")
                        }
                        .environmentObject(messageService)
                    
                    StoryView()
                        .tabItem {
                            Label("故事", systemImage: "book.closed")
                        }
                    
                    InsightView()
                        .tabItem {
                            Label("洞察", systemImage: "eye")
                        }
                }
            }
            .background(Color(.systemBackground))
            .foregroundColor(.primary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(MessageService())
    }
}
