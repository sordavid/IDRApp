//
//  IDRAppApp.swift
//  IDRApp
//
//  Created by David Sor on 3/18/26.
//

import SwiftUI
import ComposableArchitecture

@main
struct IDRAppApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    var body: some Scene {
        WindowGroup {
            CounterView(
                store: Store(initialState: CounterFeature.State()) {
                    CounterFeature()
                }
            )
            .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
