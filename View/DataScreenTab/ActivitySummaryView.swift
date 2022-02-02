//
//  ActivitySummaryView.swift
//  BikeComputer
//
//  Created by Allen Liang on 12/8/21.
//

import SwiftUI
import CoreLocation

struct ActivitySummaryView: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var showDiscardAlert: Bool = false
    @ObservedObject var summaryViewModel = ActivitySummaryViewModel()
    let lapRowFontSize: CGFloat = 16
    
    var body: some View {
        VStack {
            ScrollView {
                MapView(coordinates: viewModel.currentActivity.getCoordinates())
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                // TODO: use formatters in Utility
                VStack {
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            DataItem(name: "Distance", value: String(format: "%.2f mi", viewModel.dataMap[.distance] as? Double ?? 0.0)) // use utility method to get units
                                .frame(maxWidth: .infinity)
                            Spacer()
                            Divider()
                            Spacer()
                            DataItem(name: "Moving Time", value: "\(timeString(seconds: viewModel.dataMap[.time] as? Int ?? 0))")
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        Divider()
                        HStack {
                            Spacer()
                            DataItem(name: "Avg Speed", value: String(format: "%.1f mph", viewModel.dataMap[.avgSpeed] as? Double ?? 0.0))
                                .frame(maxWidth: .infinity)
                            Spacer()
                            Divider()
                            Spacer()
                            DataItem(name: "Avg Power", value: "\(viewModel.dataMap[.avgPower] as? Int ?? 0) w")
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        Divider()
                        HStack {
                            Spacer()
                            DataItem(name: "Avg Heart Rate", value: "\(viewModel.dataMap[.avgHeartRate] as? Int ?? -1) bpm")
                                .frame(maxWidth: .infinity)
                            Spacer()
                            Divider()
                            Spacer()
                            let (value, unit) = Utility.getDataValueString(value: viewModel.dataMap[.elevationGain], dataType: .elevationGain)
                            DataItem(name: "Elevation Gain", value: "\(value) \(unit)")
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                    }
                    .padding(.top, 16)
                }
                
                VStack {
                    HStack {
                        Text("Lap #")
                            .frame(maxWidth: .infinity)
                        Text("Time")
                            .frame(maxWidth: .infinity)
                        Text("Miles")
                            .frame(maxWidth: .infinity)
                        Text("Speed")
                            .frame(maxWidth: .infinity)
                        Text("Power")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 16)
                    
                    Divider()
                    
                    VStack {
                        ForEach(0..<(viewModel.currentActivity.laps.count)) { i in
                            let lap = viewModel.currentActivity.laps[i]
                            
                            HStack {
                                Text("\(i + 1)")
                                    .frame(maxWidth: .infinity)
                                Text(timeString(seconds: lap.lapTime))
                                    .frame(maxWidth: .infinity)
                                Text(String(format: "%.2f", lap.lapDistance))
                                    .frame(maxWidth: .infinity)
                                Text(String(format: "%.1f", lap.lapSpeed))
                                    .frame(maxWidth: .infinity)
                                Text("\(lap.lapPower)")
                                    .frame(maxWidth: .infinity)
                            }
                            .font(.system(size: lapRowFontSize))
                            
                            Divider()
                        }
                    }
                }
                
                if summaryViewModel.authState { // TODO: factor out
                    HStack {
                        Text("Upload To Strava")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Toggle("", isOn: $summaryViewModel.uploadToStrava)
                    }
                    .padding(24)
                }
                
                
                HStack {
                    Spacer()
                    Button("Discard Activity") {
                        showDiscardAlert = true
                    }
                    .alert(isPresented: $showDiscardAlert) {
                        Alert(title: Text("Discard this Activity?"),
                              message: Text("Are you sure you want to discard this activity?"),
                              primaryButton: .default(
                                Text("Cancel")
                              ),
                              secondaryButton: .destructive(
                                Text("Discard Activity"),
                                action: {
                                    presentationMode.wrappedValue.dismiss()
                                    viewModel.resetActivity()
                                }
                              )
                        )
                    }
                    .foregroundColor(.red)
                    Spacer()
                }
                .padding(.top, 16)
            }
            HStack {
                CustomButton(text: "Resume Activity", action: {
                    viewModel.resume()
                    presentationMode.wrappedValue.dismiss()
                })
                    .padding()
                
                CustomButton(text: "Save Activity", action: {
                    summaryViewModel.saveActivity(activity: viewModel.currentActivity, presentationMode: presentationMode)
                    UIApplication.shared.isIdleTimerDisabled = false
                })
                    .alert(isPresented: $summaryViewModel.showingAlert) {
                        Alert(title: Text(summaryViewModel.alertMessage), message: nil, dismissButton: .default(Text("OK"), action: {
                            presentationMode.wrappedValue.dismiss()
                        }))
                    }
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
        }
        
        
        .loadingIndicator(isPresented: $summaryViewModel.isLoading)
        
    }
    
}
