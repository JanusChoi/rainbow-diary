//
//  rainbow_dairyApp.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/12.
//

import SwiftUI

@main
struct rainbow_dairyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MessageService())
        }
    }
}
