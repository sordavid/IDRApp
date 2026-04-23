//
//  FactHistoryFeature.swift
//  IDRApp
//
//  Created by David Sor on 4/8/26.
// This file will create a TCA feature that loads saved facts from supabase and store them in app state

// gives us reducer, observable state, and reduce
import ComposableArchitecture
// gives you core swift types because we use Date and UUID
import Foundation
// gives me access to Supabase client and query methods
import Supabase

// defines TCA feature
// logic for fact history screen
@Reducer
struct FactHistoryFeature {
    // defines state for the screen and lets swiftUI view observe changes
    // Equatable lets swift compare old vs new state
    @ObservableState
    struct State: Equatable {
        // stores list of saved facts
        var facts: [SavedFact] = []
        // tracks whether data is loading and is useful for a spinner
        var isLoading = false
        // shows optional error message
        var errorMessage: String?
    }
    
    // defines all actions this feature can handle
    enum Action {
        // action to start loading facts
        case loadFacts
        // action sent when loading succeeds, carries the loaded fact
        case factsResponse([SavedFact])
        // action sent when loading fails, carries and error message
        case factsFailed(String)
        // action to delete one or more selected facts
        case deleteFacts(IndexSet)
        // action sent when delete succeeds for given factID
        case deleteFactResponse(UUID)
        // action sent when delete fails
        case deleteFactFailed(String)

    }
    
    // defines reducer logic
    var body: some Reducer<State, Action> {
        // reducer function itself, takes the state of an incomming action
        Reduce { state, action in
            // handles each action seperately
            switch action {
            // runs when app wants to fetch the fact history
            case .loadFacts:
                // mark the feature as currently loading
                state.isLoading = true
                // clear any old error messages before trying again
                state.errorMessage = nil
                // start an async effect
                return .run { send in
                    do {
                        // creates a facts constant
                        let facts: [SavedFact] = try await supabase
                        // query from fact history
                            .from("fact_history")
                        // ask for rows
                            .select()
                        // runs the query
                            .execute()
                            .value
                        // sends the result back into the reducer
                        await send(.factsResponse(facts))
                    } catch {
                        // sends failure action with message
                        await send(.factsFailed("Failed to load fact history from Supabase"))
                    }
                }
            
            // handles success action
            case let .factsResponse(facts):
                // loading is done
                state.isLoading = false
                // stores the facts in state
                state.facts = facts
                // no more side effects needed
                return .none
            
            // handles failure action
            case let .factsFailed(errorMessage):
                // loading is done
                state.isLoading = false
                // stores the error so the view can show it
                state.errorMessage = errorMessage
                return .none

            // handles delete request from list swipe actions
            case let .deleteFacts(indexSet):
                // convert UI index to DB ids
                let factIDs = indexSet.map { state.facts[$0].id }
                // remove old error message
                state.errorMessage = nil
                return .run { send in
                    do {
                        for id in factIDs {
                            try await supabase
                                .from("fact_history")
                                .delete()
                                .eq("id", value: id.uuidString)
                                .execute()

                            await send(.deleteFactResponse(id))
                        }
                    } catch {
                        await send(.deleteFactFailed("Failed to delete fact from Supabase"))
                    }
                }

            // remove deleted fact from local state
            case let .deleteFactResponse(id):
                state.facts.removeAll { $0.id == id }
                return .none

            // display deletion error
            case let .deleteFactFailed(errorMessage):
                state.errorMessage = errorMessage
                return .none
            }
        }
    }
}
