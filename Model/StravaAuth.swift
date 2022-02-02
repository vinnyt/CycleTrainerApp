//
//  StravaAuth.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/27/21.
//

import Foundation

struct StravaAuth: Codable {
    let access_token: String
    let refresh_token: String
    let expires_at: Int
}
