//
//  ContentView.swift
//  IDRApp
//
//  Created by David Sor on 3/18/26.
//

import SwiftUI
import ComposableArchitecture

// main view
struct CounterView: View {
    let store: StoreOf<CounterFeature>
    var body: some View {
        NavigationStack {
            List {
                // NavigationLink settings
                NavigationLink("Open Settings") {
                    SettingsView()
                }
                // NavigationLink for fact history
                NavigationLink("Open Fact History") {
                    FactHistoryView(
                        store: Store(initialState: FactHistoryFeature.State()) {
                            FactHistoryFeature()
                        }
                    )
                }
                // user profile section
                Section("User Profile") {
                    TextField(
                        "Enter your name",
                        text: Binding(
                            get: { store.name },
                            set: { store.send(.nameChanged($0))}
                        )
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                }
                // counter section
                Section("Counter Controls") {
                    Text("Count: \(store.tapCount)")
                }
                
                // fun fact button logic
                Section ("Fun Fact") {
                    VStack(spacing: 12) {
                        if store.isLoading {
                            ProgressView("Fetching...")
                                .frame(maxWidth: .infinity)
                        } else if let fact = store.numberFact {
                            Text(fact)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 8)
                        } else {
                            Text("No fact loaded yet.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    // get fact button
                    Button {
                        store.send(.factButtonTapped)
                    } label: {
                        Label("Get Fact", systemImage: "lightbulb")
                            .frame(maxWidth: .infinity)
                        
                    }
                    .buttonStyle(.bordered)
                    
                    // save fact button
                    Button {
                        store.send(.saveButtonTapped)
                    } label: {
                        Label("Save Fact", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    if let statusMessage = store.statusMessage {
                        Text(statusMessage)
                            .font(.headline)
                            .foregroundStyle(store.isStatusError ? .red : .green)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Move the custom UI into its own Section
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "book")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .padding()
                        
                        Text("Tap count: \(store.tapCount)")
                        if store.name.isEmpty {
                            Text("Please enter name above!")
                                .foregroundStyle(.secondary)
                                .italic()
                        } else {
                            Text("\(store.name)'s counter app")
                                .fontWeight(.bold)
                        }
                        
                        // Logic feedback
                        Group {
                            if (store.isReset) {
                                Text("Counter has been reset!")
                                    .foregroundStyle(Color.orange)
                            } else if (store.tapCount == 0) {
                                Text("Hit 'Tap me !' to get started!")
                            }
                            else if store.tapCount < 0 {
                                Text("You cannot have a negative count!")
                            } else if store.tapCount < 10 {
                                Text("Keep going!")
                            } else {
                                Text("You've hit 10!")
                            }
                        }
                        .font(.caption)
                        .italic()
                        
                        // Buttons
                        Button("Tap me!") { store.send(.incrementButtonTapped) }
                            .buttonStyle(.borderedProminent)
                        
                        Button("Decrement") { store.send(.decrementButtonTapped) }
                            .buttonStyle(.bordered)
                            .foregroundStyle(.red)
                        
                        Button("Reset") { store.send(.resetButtonTapped) }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.red)
                    }
                    .frame(maxWidth: .infinity) // This centers the content in the row
                }
            }
            .listStyle(.insetGrouped) // This makes it look like a clean iOS app
            .navigationTitle("Counter App")
            
        }
        }
}
#Preview {
    NavigationStack {
        CounterView(
            store: Store(initialState: CounterFeature.State(tapCount: 0, name: "")) {
                CounterFeature()
            }
        )
    }
}
