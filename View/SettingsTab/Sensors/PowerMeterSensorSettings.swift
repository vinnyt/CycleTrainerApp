//
//  PowerMeterSensorSettings.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/23/21.
//

import SwiftUI
import CoreBluetooth

struct PowerMeterSensorSettings: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    let fontSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            Form {
                ForEach(viewModel.discoveredPowerMeterPeripherals, id: \.identifier.uuidString) { peripheral in
                    if peripheral.identifier.uuidString == viewModel.powerMeterManager.connectedPeripheral?.identifier.uuidString {
                        HStack {
                            Text(peripheral.name ?? "NO NAME")
                                .font(.system(size: fontSize))
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.disconnectPowerMeterPeripheral()
                        }
                    } else {
                        HStack {
                            Text(peripheral.name ?? "NO NAME")
                                .font(.system(size: fontSize))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.connectToPowerMeterPeripheral(peripheral: peripheral)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.scanForPowerMeterPeripherals()
            }
            .onDisappear {
                viewModel.stopScanningForPowerMeterPeripherals()
            }
            
            if viewModel.discoveredPowerMeterPeripherals.count == 0 {
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

