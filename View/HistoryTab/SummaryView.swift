//
//  SummaryView.swift
//  SummaryView
//
//  Created by Allen Liang on 9/8/21.
//

import SwiftUI
import CoreLocation
import SwiftyXML

struct SummaryView: View {
    @ObservedObject var viewModel = SummaryViewModel()
    var savedActivity: NewSavedActivity
    let sectionLabelFontSize: CGFloat = 16
    let spacingBetweenSections: CGFloat = 16
    let lapRowFontSize: CGFloat = 16
    @State var showOptions = false
    
    var body: some View {
        ZStack {
            ScrollView {
                ZStack {
                    MapView(coordinates: savedActivity.coordinates)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 300)
                }
                .padding(.bottom, spacingBetweenSections)
                
                VStack(spacing: 0) { // summary section
                    HStack {
                        Text("Summary")
                            .font(.system(size: sectionLabelFontSize))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.leading, 8)
                    .padding(.bottom, 4)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            DataItem(name: "Distance", value: String(format: "%.2f mi", savedActivity.distance)) // use utility method to get units
                                .frame(maxWidth: .infinity)
                            Spacer()
                            Divider()
                            Spacer()
                            DataItem(name: "Moving Time", value: "\(timeString(seconds: savedActivity.time))")
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        Divider()
                        HStack {
                            Spacer()
                            DataItem(name: "Avg Speed", value: String(format: "%.1f mph", savedActivity.avgSpeed))
                                .frame(maxWidth: .infinity)
                            Spacer()
                            Divider()
                            Spacer()
                            DataItem(name: "Avg Power", value: "\(savedActivity.avgPower) w")
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        Divider()
                        HStack {
                            Spacer()
                            DataItem(name: "Avg Heart Rate", value: "\(savedActivity.avgHeartRate) bpm")
                                .frame(maxWidth: .infinity)
                            Spacer()
                            Divider()
                            Spacer()
                            DataItem(name: "Elevation Gain", value: "\(savedActivity.elevationGain) ft")
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(Color(uiColor: .secondarySystemBackground))
                }
                .padding(.bottom, spacingBetweenSections)
                
                
                VStack(spacing: 0) { // laps section
                    HStack {
                        Text("Laps")
                            .font(.system(size: sectionLabelFontSize))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    .padding(.leading, 8)
                    
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
                            ForEach(0..<savedActivity.laps.count) { i in
                                let lap = savedActivity.laps[i]
                                
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
                    .padding(.bottom, 16)
                    .background(Color(uiColor: .secondarySystemBackground))
                }
                
            }
            .navigationTitle("Summary")
            .toolbar {
                Button(action: {
                    showOptions = true
                }) {
                    Image(systemName: "ellipsis")
                }
            }
            .successIndicator(isPresented: $viewModel.showingSuccessIndicator)
            .sheet(isPresented: $viewModel.showUIActivityController) {
                UIActivityViewControllerView(data: [viewModel.gpxURL!])
            }
            .confirmationDialog("Options", isPresented: $showOptions, titleVisibility: .visible) {
                Button("Export GPX") {
                    viewModel.exportGpx(savedActivity: savedActivity)
                }
                if viewModel.authState {
                    Button("Upload To Strava") {
                        viewModel.uploadToStrava(savedActivity: savedActivity)
                    }
                }
            }
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text(viewModel.errorMessage), message: nil)
            }
        }
        .loadingIndicator(isPresented: $viewModel.isLoading)
    }
}

class SummaryViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showUIActivityController = false
    @Published var showingAlert = false
    @Published var showingSuccessIndicator = false
    var authState: Bool
    var gpxURL: URL?
    var errorMessage = "An error has occurred."
    
    init() {
        self.authState = UserDefaults.standard.bool(forKey: StravaKeys.authState.rawValue)
    }
    
    func exportGpx(savedActivity: NewSavedActivity) {
        dismissActivityController()
        showLoading()
        DispatchQueue.global(qos: .userInitiated).async {
            self.gpxURL = Utility.generateGpxUrl(savedActivity: savedActivity)
            self.dismissLoading()
            self.showActivityController()
        }
    }
    
    func uploadToStrava(savedActivity: NewSavedActivity) { // TODO: refactor to use loadingIndicator
        showLoading()
        DispatchQueue.global(qos: .userInitiated).async {
            let url = Utility.generateGpxUrl(savedActivity: savedActivity)
            StravaAPI.shared.uploadActivity(gpxURL: url) { result in
                self.dismissLoading()
                switch result {
                case .failure(_):
                    self.showAlert(message: "Error uploading Activity.")
                case .success(_):
                    self.showSuccessIndicator()
                    break
                }
            }
        }
    }
    
    private func showSuccessIndicator() {
        self.showingSuccessIndicator = true
    }
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showingAlert = true
        }
    }
    
    private func showLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }
    
    private func dismissLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
        
    }
    
    private func showActivityController() {
        DispatchQueue.main.async {
            self.showUIActivityController = true
        }
    }
    
    private func dismissActivityController() {
        DispatchQueue.main.async {
            self.showUIActivityController = false
        }
    }
    
    
}
