//
//  SpeedSensorSetting.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/30/21.
//

import SwiftUI

struct SpeedSensorSetting: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    let fontSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            Form {
                ForEach(viewModel.discoveredSpeedPeripherals, id: \.identifier.uuidString) { peripheral in
                    if peripheral.identifier.uuidString == viewModel.speedSensorManager.connectedPeripheral?.identifier.uuidString {
                        HStack {
                            Text(peripheral.name ?? "NO NAME")
                                .font(.system(size: fontSize))
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.disconnectSpeedPeripheral()
                        }
                    } else {
                        HStack {
                            Text(peripheral.name ?? "NO NAME")
                                .font(.system(size: fontSize))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.connectToSpeedPeripheral(peripheral: peripheral)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.scanForSpeedPeripherals()
            }
            .onDisappear {
                viewModel.stopScanningForSpeedPeripherals()
            }
            
            if viewModel.discoveredSpeedPeripherals.count == 0 {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(3)
                        .frame(width: 100, height: 100)
                    Spacer()
                }
            }
        }
        
    }
}

