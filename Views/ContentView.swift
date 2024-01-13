import SwiftUI

struct ContentView: View {
    @StateObject var chatStore: ChatStore
    @State private var messageText: String = ""
    @State private var messages: [(text: String, isUser: Bool, date: Date)] = []
    @State private var isTextFieldVisible: Bool = true
    
    var messageService = MessageService()
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏视图
            HStack {
                TabView {
                    TodayView(
                        store: chatStore
                    )
                        .tabItem {
                            Label("Today", systemImage: "calendar")
                        }
                        .environmentObject(messageService)
                    
                    StoryView()
                        .tabItem {
                            Label("Story", systemImage: "book.closed")
                        }
                    
                    InsightView()
                        .tabItem {
                            Label("Insight", systemImage: "eye")
                        }
                    
                    PersonView()
                        .tabItem {
                            Label("My", systemImage: "person")
                        }
                }
            }
            .background(Color(.systemBackground))
            .foregroundColor(.primary)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environmentObject(MessageService())
//    }
//}
