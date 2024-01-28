import SwiftUI

struct testStoryView: View {
    var body: some View {
        List {
            Text("Something")
        }
        .navigationTitle("Story")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: generateSummary) {
                    Text("Generate")
                }
            }
        }
    }
}

private func generateSummary() {
    print("Generate button tapped")
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            testStoryView()
        }
    }
}
