//
//  SupabaseClient.swift
//  IDRApp
//
//  Created by David Sor on 4/8/26.
//

import Supabase
import Foundation

// create an appConfig for cleanliness
enum AppConfig {
    static let supabaseURL = URL(string: "https://jnhdqffjtniznjciwirw.supabase.co")!
    static let supabaseKey = "sb_publishable_sbD5e4mSP7BHRjvVps_AWA_xx_Uj-tW"
}

// create the connection
let supabase = SupabaseClient(
    supabaseURL: AppConfig.supabaseURL,
    supabaseKey: AppConfig.supabaseKey
)

