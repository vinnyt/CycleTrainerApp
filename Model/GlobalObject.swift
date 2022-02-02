//
//  GlobalObject.swift
//  BikeComputer
//
//  Created by Allen Liang on 11/17/21.
//

import Foundation
import SwiftUI

class GlobalObject: ObservableObject {
    static let shared = GlobalObject()
    @Published var hudIsPresented = false
    private(set) var hudSystemImage: String = ""
    private(set) var hudMessage: String = ""
    
    private init() {}
    
    func show(systemImage: String, message: String) {
        hudSystemImage = systemImage
        hudMessage = message
        withAnimation {
            hudIsPresented = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.hudIsPresented = false
            }
        }
    }
}
