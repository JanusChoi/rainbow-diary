//
//  SettingsView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/3.
//

import SwiftUI
import OpenAI

struct PersonView: View {
    @StateObject var chatStore: ChatStore
    @State private var openaiKey: String = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("Input your OpenAI key")
            SecureField("sk-XXXXXX", text: $openaiKey)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: {
                withAnimation {
                    proceedToSave()
                }
            }, label: {
                Text("Submit")
            })
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Key Saved"), message: Text("Your OpenAI key has been saved."), dismissButton: .default(Text("OK")))
        }
    }
    
    private func proceedToSave() {
        UserDefaults.standard.set(openaiKey, forKey: "openaiKey")
        let client = OpenAI(apiToken: openaiKey)
        chatStore.updateClient(client)
        showAlert = true
    }
}
