//
//  HeartRateSensorSettings.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/23/21.
//

import SwiftUI

struct HeartRateSensorSettings: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    let fontSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            Form {
                ForEach(viewModel.discoveredHeartRatePeripherals, id: \.identifier.uuidString) { peripheral in
                    if peripheral.identifier.uuidString == viewModel.heartRateManager.connectedPeripheral?.identifier.uuidString {
                        HStack {
                            Text(peripheral.name ?? "NO NAME")
                                .font(.system(size: fontSize))
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.disconnectHeartRatePeripheral()
                        }
                    } else {
                        HStack {
                            Text(peripheral.name ?? "NO NAME")
                                .font(.system(size: fontSize))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.connectToHeartRatePeripheral(peripheral: peripheral)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.scanForHeartRatePeripherals()
            }
            .onDisappear {
                viewModel.stopScanningForHeartRatePeripherals()
            }
            
            if viewModel.heartRateManager.discoveredPeripherals.count == 0 {
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
