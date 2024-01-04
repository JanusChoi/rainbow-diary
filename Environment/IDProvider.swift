//
//  IDProvider.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/4.
//

import SwiftUI

private struct IDProviderKey: EnvironmentKey {
    static let defaultValue: () -> String = {
        UUID().uuidString
    }
}

extension EnvironmentValues {
    public var idProviderValue: () -> String {
        get { self[IDProviderKey.self] }
        set { self[IDProviderKey.self] = newValue }
    }
}

extension View {
    public func idProviderValue(_ idProviderValue: @escaping () -> String) -> some View {
        environment(\.idProviderValue, idProviderValue)
    }
}
