//
//  StatsViewModel.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/4/21.
//

import Foundation

class StatsViewModel: ObservableObject, ProfileObserver {
    @Published var bestPowers = Profile.default.bestPowers
    @Published var isCalculating = Profile.default.isCalculatingBestPowers
    @Published var ftp = Profile.default.ftp
    
    init() {
        Profile.default.addListener(listener: self)
    }
    
    func calculatingBestPowersDidUpdate() {
        DispatchQueue.main.async {
            self.isCalculating = Profile.default.isCalculatingBestPowers
            self.bestPowers = Profile.default.bestPowers
        }
    }
    
    func setFtp(ftp: Int) {
        Profile.default.setFTP(ftp: ftp)
        self.ftp = ftp
    }
}
