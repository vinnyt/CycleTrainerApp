//
//  IntervalDataScreen.swift
//  IntervalDataScreen
//
//  Created by Allen Liang on 9/22/21.
//

import SwiftUI

struct IntervalDataScreen: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    @State var message: String = ""
    var zoneNames = [
        "Zone 1": "Zone 1 (Recovery)",
        "Zone 2": "Zone 2 (Endurance)",
        "Zone 3": "Zone 3 (Tempo)",
        "Zone 4": "Zone 4 (Threshold)",
        "Zone 5": "Zone 5 (VO2)",
        "Zone 6": "Zone 6 (Anaerobic)"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Target Zone", selection: $viewModel.selectedZone) {
                ForEach(Zone.allCases, id: \.self) { zone in
                    Text(zone.rawValue)
                }
            }
            .onChange(of: viewModel.selectedZone, perform: { value in
                viewModel.handleSelectedPowerZoneChange()
            })
            .padding(.top, 8)
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.bottom, 16)
            .pickerStyle(.segmented)
            
            Text("\(zoneNames[viewModel.selectedZone.rawValue] ?? "")")
                .font(.system(size: 14))
                .bold()
            
            GeometryReader { geo in
                    ZStack {
                        HStack {
                            Rectangle()
                                .fill(Color(uiColor: powerBarColor()))
                                .frame(width: geo.size.width * viewModel.powerZonePercentage, height: 50, alignment: .leading)
//                                .frame(width: geo.size.width * 0.70, height: 50, alignment: .leading)
                                .animation(
                                    Animation.easeInOut(duration: 1)
                                )
                            Spacer()
                        }
                        HStack {
                            Text("\(viewModel.powerRange[0])w")
                                .font(.custom("Menlo", size: 20))
                            Spacer()
                            Text("\(viewModel.threeSecondPower)w")
                                .font(.custom("Menlo", size: 38))
                            Spacer()
                            Text("\(viewModel.powerRange[1])w")
                                .font(.custom("Menlo", size: 20))
                        }
                        .padding()

                    }
            }
            Spacer()
        }
    }
    
    func powerBarColor() -> UIColor{
        if viewModel.threeSecondPower < viewModel.powerRange[0] {
            return .yellow
        } else if viewModel.threeSecondPower >= viewModel.powerRange[0] &&
                    viewModel.threeSecondPower <= viewModel.powerRange[1] {
            return .blue
        } else {
            return .purple
        }
    }
    
}

struct IntervalDataScreen_Previews: PreviewProvider {
    static var previews: some View {
        IntervalDataScreen()
            .environmentObject(PeripheralViewModel())
    }
}
