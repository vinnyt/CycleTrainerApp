//
//  DataScreenViewModel.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/19/21.
//

import Foundation
import UIKit

class DataScreenViewModel: ObservableObject {
    @Published var dataScreens = Profile.default.dataScreens
    
    init() {
        Profile.default.addListener(listener: self)
    }
}

extension DataScreenViewModel: ProfileObserver {
    func profileDataScreensDidUpdate() {
        dataScreens = Profile.default.dataScreens
    }
}


