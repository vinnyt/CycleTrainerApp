//
//  BikeComputerApp.swift
//  BikeComputer
//
//  Created by Allen Liang on 8/19/21.
//

import SwiftUI

@main
struct BikeComputerApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

// TODO: save state so activity can be resumed incase app is terminated
// TODO: auto detect ftp increase
// TODO: give ids to savedActivity
// TODO: best Powers save a reference to savedActivity
// TODO: redesign how data field data is updated, don't use datamap anymore because it updates other fields unnecessarily
// TODO: improve grade % calculation
