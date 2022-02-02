//
//  CustomDataScreen.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/5/21.
//

import SwiftUI

struct DataScreen: View { // TODO: rename to DataScreenPage
    var screenLayout: ScreenLayout
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ForEach(0..<screenLayout.dataRows.count, id: \.self) { i in
                    let dataRow = screenLayout.dataRows[i]
                    if dataRow.dataItems.count == 1 {
                        FullRowDataField(dataItem: dataRow.dataItems[0], size: dataRow.size)
                            .frame(width: geo.size.width, height: (geo.size.height / 8) * CGFloat(dataRow.size))
                    } else {
                        SplitRowDataField(dataItemOne: dataRow.dataItems[0], dataItemTwo: dataRow.dataItems[1], size: dataRow.size)
                            .frame(width: geo.size.width, height: (geo.size.height / 8) * CGFloat(dataRow.size))
                    }
                    Divider()
                }
                Spacer()
            }
        }
    }
}

struct DataFieldView: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    var dataItem: LayoutDataItem
    
    var body: some View {
        VStack {
            if dataItem.dataType == .map {
                NavigationDataScreenView()
                    .edgesIgnoringSafeArea(.top)
            } else if dataItem.dataType == .interval {
                IntervalDataScreen()
            }
        }
    }
}

struct FullRowDataField: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    var dataItem: LayoutDataItem
    var size: Int
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                if dataItem.dataType == .map {
                    NavigationDataScreenView()
                        .edgesIgnoringSafeArea(.top)
                } else if dataItem.dataType == .interval {
                    IntervalDataScreen()
                } else {
                    Spacer()
                    Text(DataTypeDisplayName(dataType: dataItem.dataType))
                        .font(.system(size: 16, weight: .regular))
                    
                    let (value, unit) = Utility.getDataValueString(value: viewModel.dataMap[dataItem.dataType], dataType: dataItem.dataType)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(value)
                            .font(.custom("Menlo", size: CGFloat(38 + ((size - 1) * 24))))
                        Text(unit)
                            .font(.system(size: CGFloat(16 + ((size - 1) * 16)), weight: .regular))
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct SplitRowDataField: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    var dataItemOne: LayoutDataItem
    var dataItemTwo: LayoutDataItem
    var size: Int
    
    var body: some View {
            HStack(spacing: 0){
                VStack {
                    Spacer()

                    Text(DataTypeDisplayName(dataType: dataItemOne.dataType))
                        .font(.system(size: 16, weight: .regular))
                    
                    let (value, unit) = Utility.getDataValueString(value: viewModel.dataMap[dataItemOne.dataType], dataType: dataItemOne.dataType)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(value)
                            .font(.custom("Menlo", size: 38))
                        Text(unit)
                            .font(.system(size: 16, weight: .regular))
                    }
                        
                    Spacer()

                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack {
                    Spacer()

                    Text(DataTypeDisplayName(dataType: dataItemTwo.dataType))
                        .font(.system(size: 16, weight: .regular))
                    
                    let (value, unit) = Utility.getDataValueString(value: viewModel.dataMap[dataItemTwo.dataType], dataType: dataItemTwo.dataType)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(value)
                            .font(.custom("Menlo", size: 38))
                        Text(unit)
                            .font(.system(size: 16, weight: .regular))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
    }
}

func DataTypeDisplayName(dataType: DataType) -> String {
    switch dataType {
    case .power:
        return "Power"
    case .heartRate:
        return "Heart Rate"
    case .cadence:
        return "Cadence"
    case .speed:
        return "Speed"
    case .time:
        return "Time"
    case .distance:
        return "Distance"
    case .threeSecondPower:
        return "3s Power"
    case .lapTime:
        return "Lap Time"
    case .lapPower:
        return "Lap Power"
    case .map:
        return "Map"
    case .interval:
        return "Interval"
    case .grade:
        return "Grade %"
    case .altitude:
        return "Elevation"
    case .elevationGain:
        return "Ascent"
    case .avgSpeed:
        return "Avg Speed"
    case .avgHeartRate:
        return "Avg HR"
    default:
        return ""
    }
}

struct DataScreen_Previews: PreviewProvider {
    static var previews: some View {
        DataScreen(screenLayout: dummyScreenLayout)
            .environmentObject(PeripheralViewModel())
    }
}
