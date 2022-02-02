//
//  DataScreenView.swift
//  BikeComputer
//
//  Created by Allen Liang on 8/22/21.
//

import SwiftUI
import CoreLocation
import MapKit

struct DataScreenView: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    @ObservedObject var dataScreenViewModel: DataScreenViewModel
    @State var showEndActivityAlert = false
    @State var currentIndex = 0
    @State var showingActivitySummary = false
    @State var showDataScreens = true // to show the map again if another map was rendered
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if showDataScreens {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<dataScreenViewModel.dataScreens.count, id: \.self) { index in
                            DataScreen(screenLayout: dataScreenViewModel.dataScreens[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: geo.size.height * 7/8)
                }
                
                
                CustomTabIndicator(count: dataScreenViewModel.dataScreens.count, current: $currentIndex)
                    .padding(.top, 4)
                    ZStack {
                        CustomButton(text: "Start", action: startActivity)
                            .padding()
                            .opacity(viewModel.activityStatus == .notStarted ? 1 : 0)
                        
                        HStack {
                            CustomButton(text: "Pause", action: {
                                viewModel.userPaused()
                            })
                                .padding()
                            
                            CustomButton(text: "Lap", action: {
                                viewModel.lap()
                            })
                                .padding()
                        }
                        .frame(maxWidth: viewModel.activityStatus == .started ? .infinity : 0, maxHeight: .infinity)
                        
                        HStack {
                            CustomButton(text: "Resume Activity", action: {
                                viewModel.resume()
                            })
                                .padding()
                            
                            CustomButton(text: "End Activity", action: {
                                showEndActivityAlert = true
                            })
                                .padding()
                        }
                        .frame(maxWidth: (viewModel.activityStatus == .userPaused ||
                                          viewModel.activityStatus == .autoPaused) ? .infinity : 0,
                               maxHeight: .infinity)
                    }
                    .frame(maxHeight: .infinity)
                
            }
        }
        .fullScreenCover(isPresented: $showingActivitySummary) {
            ActivitySummaryView()
        }
        .alert(isPresented: $showEndActivityAlert) {
            Alert(title: Text("End this Activity?"),
                  message: Text("Are you sure you want to end this activity?"),
                  primaryButton: .default(
                    Text("Cancel")
                  ),
                  secondaryButton: .destructive(
                    Text("End Activity"),
                    action: {
                        showingActivitySummary = true
                    }
                  )
            )
        }
        .onAppear() {
            showDataScreens = true
        }
        .onDisappear() {
            showDataScreens = false
        }
    }
    
    func startActivity() {
        viewModel.startActivity()
    }
}

struct DataScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DataScreenView(dataScreenViewModel: DataScreenViewModel())
            .environmentObject(PeripheralViewModel())
    }
}

func timeString(seconds: Int) -> String {
    let (h, m , s) = secondsToHoursMinutesSeconds(seconds: seconds)
    
    var timeString = ""
    if h > 0 {
        if h < 10 {
            timeString += "0\(h):"
        } else {
            timeString += "\(h):"
        }
        if m < 10 {
            timeString += "0\(m):"
        } else {
            timeString += "\(m):"
        }
    } else {
        if m < 10 {
            timeString += "0\(m):"
        } else {
            timeString += "\(m):"
        }
    }
    
    if s < 10 {
        timeString += "0\(s)"
    } else{
        timeString += "\(s)"
    }
    
    return timeString
}

func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

struct DataItem: View {
    var name: String
    var value: String
    
    var body: some View {
        VStack {
            Text(name)
                .font(.custom("Menlo", size: 12))
            Text(value)
                .font(.custom("Menlo", size: 24))
                .bold()
        }
        
    }
}

struct NavigationDataScreenView: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    @State var lockMap = true
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.blue
                ActivityMapView(lockMap: $lockMap)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                InvisibleView()
                    .frame(maxWidth: lockMap ? .infinity : 0, maxHeight: .infinity)

                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            lockMap.toggle()
                        }) {
                            if lockMap {
                                Image(systemName: "lock.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "lock.open.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                        .padding(.bottom)
                    }
                }
            }
        }
    }
}



enum Zone: String, CaseIterable, Identifiable {
    var id: String { return self.rawValue}
    
    case zone1 = "Zone 1"
    case zone2 = "Zone 2"
    case zone3 = "Zone 3"
    case zone4 = "Zone 4"
    case zone5 = "Zone 5"
    case zone6 = "Zone 6"
}
