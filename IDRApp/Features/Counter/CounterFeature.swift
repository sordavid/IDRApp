//
//  CounterFeature.swift
//  IDRApp
//
//  Created by David Sor on 3/26/26.
//


import ComposableArchitecture
import Foundation
import Supabase

// struct created for formatting purposes
struct FactItem: Decodable {
    let fact: String
}

// new saved fact info
struct NewSavedFact: Encodable {
    let factText: String
    let countAtTime: Int
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case factText = "fact_text"
        case countAtTime = "count_at_time"
        case userName = "user_name"
    }
}

@Reducer
struct CounterFeature {
    @ObservableState
    struct State: Equatable {
        var tapCount: Int = 0
        var name: String = ""
        var isReset: Bool = false
        // number fact
        var numberFact: String? = nil
        // loading state
        var isLoading: Bool = false
        // status message for validation
        var statusMessage: String? = nil
        var isStatusError = false
    }
    
    enum Action {
        case incrementButtonTapped
        case decrementButtonTapped
        case resetButtonTapped
        case factButtonTapped
        case factResponse(String)
        case nameChanged(String)
        case saveButtonTapped
        // alert message
        case saveSucceeded
        case saveFailed(String)
        
        
    }
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.tapCount += 1
                state.isReset = false // set reset state back to false
                return .run { _ in print("Increased!") } // side effect
                
            case .decrementButtonTapped:
                guard state.tapCount > 0 else { return .none }
                
                state.tapCount -= 1
                return .run { _ in print("Decreased!" )}
                
                // reset button
            case .resetButtonTapped:
                state.tapCount = 0
                state.isReset = true
                state.name = ""
                return .run { _ in print("Reset!" )}
                
                // fact button tap
            case .factButtonTapped:
                state.isLoading = true
                state.numberFact = nil
                return .run { [count = state.tapCount] send in
                    do {
                        // creates a valid url, if it fails, stops and sends and error
                        guard let url = URL(string: "https://api.api-ninjas.com/v1/facts") else {
                            await send(.factResponse("Invalid URL"))
                            return
                        }
                        // creates a request object from the url with api key
                        var request = URLRequest(url: url)
                        // get request
                        request.httpMethod = "GET"
                        // sets the api key
                        request.setValue("lYeRA5uLyc6kSQplqFxMeg4FAMyErEwEXdWhSmjV", forHTTPHeaderField: "X-Api-Key")
                        
                        // sends url request, returning the data (body of the response)
                        let (data, _) = try await URLSession.shared.data(for: request)
                        
                        // decode the data into a string
                        let facts = try JSONDecoder().decode([FactItem].self, from: data)
                        let fact = facts.first?.fact ?? "No fact found"
                        
                        // send result back to reducer
                        await send(.factResponse(fact))
                    } catch {
                        // handle network errors
                        await send(.factResponse("Could not connect to the server"))
                    }
                }
                
                // fact button response
            case let .factResponse(fact):
                state.isLoading = false
                state.numberFact = fact
                return .none
                
                // name change
            case let .nameChanged(newName):
                state.name = newName
                return .none
                
                // saved button response
            case .saveButtonTapped:
                // prevents submitting an empty fact
                guard let fact = state.numberFact else {
                    state.statusMessage = "Get a fact before trying to save it."
                    state.isStatusError = true
                    return .none
                }
                // prevents empty names
                guard !state.name.isEmpty else {
                    state.statusMessage = "Enter your name before saving a fact."
                    state.isStatusError = true
                    return .none
                }
                
                // set as main actor
                return .run { @MainActor [fact = fact, count = state.tapCount, name = state.name] send in
                    do {
                        // first check if this fact exists in the db
                        let existingFacts: [SavedFact] = try await supabase
                            .from("fact_history")
                            .select()
                            .eq("fact_text", value: fact)
                            .execute()
                            .value
                        
                        // If existing fact is found, dont save it again
                        if !existingFacts.isEmpty {
                            send(.saveFailed("This fact is already saved in your history"))
                            return // prevent continuing
                        }
                        
                        // store the NEW fact
                        let newFact = NewSavedFact(
                            factText: fact,
                            countAtTime: count,
                            userName: name
                        )
                        // connect to supabase and insert
                        try await supabase
                            .from("fact_history")
                            .insert(newFact)
                            .execute()
                        
                        send(.saveSucceeded)
                    } catch {
                        send(.saveFailed("Failed to save fact to Supabase: \(error.localizedDescription)"))
                    }
                }
            case .saveSucceeded:
                state.statusMessage = "Fact saved."
                state.isStatusError = false
                return .none
                
            case .saveFailed(let message):
                state.statusMessage = message
                return .none
            

            }
            
        }
    }
}
