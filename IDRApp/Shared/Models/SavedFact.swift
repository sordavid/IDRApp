//
//  SavedFact.swift
//  IDRApp
//
//  Created by David Sor on 4/8/26.
//

import Foundation

// codable - let swift convert this struct to and from json
// identifiable - tells swiftUI this model has a stable ID
// equatable - lets swift compare two SavedFact values as instances
// swift keys
struct SavedFact: Codable , Identifiable, Equatable {
    let id: UUID
    let factText: String
    let countAtTime: Int
    let userName: String?
    let createdAt: Date
    
    // supabase keys
    enum CodingKeys: String, CodingKey {
        case id
        case factText = "fact_text"
        case countAtTime = "count_at_time"
        case userName = "user_name"
        case createdAt = "created_at"
    }
}

