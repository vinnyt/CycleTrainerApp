//
//  StatsSettings.swift
//  StatsSettings
//
//  Created by Allen Liang on 9/17/21.
//

import SwiftUI

struct StatsRowView: View {
    
    var body: some View {
        return NavigationLink(destination: StatsSettingView()) {
            HStack(spacing: 16) {
                Text("Stats")
                    .font(.system(size: 20))
                    .frame(width: 150,height: 40, alignment: .leading)
            }
        }
    }
}

struct StatsSettingView: View {
    @State var userFtp = ""
    let zoneNames = ["Recovery", "Endurance", "Tempo", "Threshold", "VO2", "Anaerobic"]
    let bestPowersArray = [
        [
            "name" : "Max",
            "bestPower" : BestPowers.maxPower
        ],
        [
            "name" : "Five Second",
            "bestPower" : BestPowers.fiveSecondPower
        ],
        [
            "name" : "One Minute",
            "bestPower" : BestPowers.oneMinutePower
        ],
        [
            "name" : "Three Minute",
            "bestPower" : BestPowers.threeMinutePower
        ],
        [
            "name" : "Five Minute",
            "bestPower" : BestPowers.fiveMinutePower
        ],
        [
            "name" : "Ten Minute",
            "bestPower" : BestPowers.tenMinutePower
        ],
        [
            "name" : "Twenty Minute",
            "bestPower" : BestPowers.twentyMinutePower
        ]
    ]
    
    @State var calculatingPowersMessage = ""
    @ObservedObject var viewModel: StatsViewModel = StatsViewModel()
    
    var body: some View {
        Form {
            HStack {
                Text("FTP: ")
                TextField("\(viewModel.ftp)w", text: $userFtp)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Save") {
                                validateFTP(input: userFtp)
                                hideKeyboard()
                            }
                        }
                    }
            }
            
            Section(header: Text("Power Zones")) {
                ForEach(1 ..< 7) { num in
                    let low = Profile.default.zones["\(num)"]?[0]
                    let high = Profile.default.zones["\(num)"]?[1]
                    let rangeString = getRangeString(low: low ?? 0, high: high ?? 0)

                    HStack {
                        Text("Zone \(num)  (\(zoneNames[num - 1]))")
                        Spacer()
                        Text(rangeString)
                    }
                    
                }
            }
            Section(header: HStack {
                Text("Best Powers")
                Spacer()
                Text(viewModel.isCalculating ? "Calculating..." : "Up To Date ✅")
            }){
                ForEach(0..<bestPowersArray.count) { i in
                    let power = bestPowersArray[i]["bestPower"] as! BestPowers
                    HStack {
                        Text(bestPowersArray[i]["name"] as? String ?? "")
                        Spacer()
                        Text("\(viewModel.bestPowers[power] ?? 0)w")
                    }
                }
            }
        }
        .onTapGesture {
            userFtp = ""
            hideKeyboard()
        }
        .navigationTitle("Stats")
    }
    
    func validateFTP(input: String) {
        if let ftp = Int(input) {
            viewModel.setFtp(ftp: ftp)
        } else {
            print("invalid ftp input")
        }
    }
    
    func getRangeString(low: Int, high: Int) -> String {
        if high > 1000 {
            return "\(low)w+"
        }
        return "\(low)w - \(high)w"
    }
    
}

struct StatsSettingView_Previews: PreviewProvider {
    static var previews: some View {
        StatsSettingView()
    }
}

