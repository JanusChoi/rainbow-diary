//
//  SettingsView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/3.
//

import SwiftUI

struct PersonView: View {
    @State private var openaiKey: String = ""
    var body: some View {
        VStack {
            Text("Input your OpenAI key")
            TextField("sk-XXXXXX", text: $openaiKey)
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
    }
    
    private func proceedToSave() {
        UserDefaults.standard.set(openaiKey, forKey: "openaiKey")
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView()
    }
}
