//
//  DevView.swift
//  CycleTrainer
//
//  Created by Allen Liang on 1/4/22.
//

import SwiftUI

struct DevView: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    
    var body: some View {
        VStack {
            Text("gps speed: \(String(format: "%.1f", (viewModel.dataMap[.speed] as? Double ?? -1.0)))")
            Text("sensor speed: \(String(format: "%.1f", viewModel.speedFromSensor))")
            
            Text("PM cadence: \(viewModel.dataMap[.cadence] as? Int ?? -1)")
            Text("sensor cadence: \(viewModel.cadenceFromSensor)")
        }
        .font(.system(size: 30))
    }
}
