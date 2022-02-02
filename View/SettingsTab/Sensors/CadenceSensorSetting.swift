//
//  CadenceSensorSetting.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/30/21.
//

import SwiftUI

struct CadenceSensorSetting: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    let fontSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            Form {
                ForEach(viewModel.discoveredCadencePeripherals, id: \.identifier.uuidString) { peripheral in
                    if peripheral.identifier.uuidString == viewModel.cadenceSensorManager.connectedPeripheral?.identifier.uuidString {
                        HStack {
                            Text(peripheral.name ?? "NO NAME")
                                .font(.system(size: fontSize))
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.disconnectCadencePeripheral()
                        }
                    } else {
                        HStack {
                            Text(peripheral.name ?? "NO NAME")
                                .font(.system(size: fontSize))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.connectToCadencePeripheral(peripheral: peripheral)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.scanForCadencePeripherals()
            }
            .onDisappear {
                viewModel.stopScanningForCadencePeripherals()
            }
            
            if viewModel.discoveredCadencePeripherals.count == 0 {
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
