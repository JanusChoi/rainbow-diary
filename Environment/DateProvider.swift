//
//  DateProvider.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2024/1/4.
//

import SwiftUI

private struct DateProviderKey: EnvironmentKey {
    static let defaultValue: () -> Date = Date.init
}

extension EnvironmentValues {
    public var dateProviderValue: () -> Date {
        get { self[DateProviderKey.self] }
        set { self[DateProviderKey.self] = newValue }
    }
}

extension View {
    public func dateProviderValue(_ dateProviderValue: @escaping () -> Date) -> some View {
        environment(\.dateProviderValue, dateProviderValue)
    }
}
