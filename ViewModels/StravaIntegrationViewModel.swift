//
//  StravaIntegrationViewModel.swift
//  BikeComputer
//
//  Created by Allen Liang on 12/2/21.
//

import Foundation

class StravaIntegrationViewModel: ObservableObject {
    @Published var authState: Bool
    @Published var shareActivity: Bool
    
    init() {
        authState = UserDefaults.standard.bool(forKey: StravaKeys.authState.rawValue)
        shareActivity = UserDefaults.standard.bool(forKey: StravaKeys.shareActivity.rawValue)
        print(authState)
    }
    
    func setAuthState(state: Bool) {
        DispatchQueue.main.async {
            self.authState = state
            
        }
        UserDefaults.standard.set(state, forKey: StravaKeys.authState.rawValue)
    }
    
    func setShareActivityState(state: Bool) {
        DispatchQueue.main.async {
            self.shareActivity = state
        }
        UserDefaults.standard.set(state, forKey: StravaKeys.shareActivity.rawValue)
    }
    
    func disconnectStrava() {
        setAuthState(state: false) // TODO: Deauthorization tokens with strava api
        setShareActivityState(state: false)
    }
}
