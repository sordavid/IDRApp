//
//  FactHistoryView.swift
//  IDRApp
//
//  Created by David Sor on 4/8/26.
//

import SwiftUI
import ComposableArchitecture

struct FactHistoryView: View {
    let store: StoreOf<FactHistoryFeature>
    
    var body: some View {
        Text("Pull down to refresh!")
            .font(.caption)
            .foregroundStyle(Color.secondary)
        List {
            if store.isLoading {
                ProgressView("Loading facts...")
            } else if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(Color.red)
            } else if store.facts.isEmpty {
                Text("No saved facts yet.")
            } else {
                ForEach(store.facts) { fact in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(fact.factText)
                        Text("User: \(fact.userName ?? "Unknown")")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        Text("Count: \(fact.countAtTime)")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .onDelete { indexSet in
                    store.send(.deleteFacts(indexSet))
                }
            }
        }
        .navigationTitle(Text("Fact History"))
        // allow pull to refresh
        .refreshable {
            store.send(.loadFacts)
        }
        .onAppear {
            store.send(.loadFacts)
        }
        
    }
}

#Preview {
    NavigationStack {
        FactHistoryView(
            store: Store(initialState: FactHistoryFeature.State()) {
                FactHistoryFeature()
            }
        )
    }
}
