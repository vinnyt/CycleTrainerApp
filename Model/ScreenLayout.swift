//
//  ScreenLayout.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/5/21.
//

import Foundation



struct ScreenLayout: Codable {
    let MAX_SIZE = 8
    var dataRows = [LayoutDataRow]()
    var spaceAvailable: Int {
        let sum = dataRows.map{ $0.size}.reduce(0, +)
        return MAX_SIZE - sum
    }
    
}

struct LayoutDataRow: Codable {
    var dataItems = [LayoutDataItem]() // TODO: this can just be [DataType]
    var size = 1

}

struct LayoutDataItem: Codable { // TODO: don't need this type
    var dataType: DataType
 
    init(dataType: DataType) {
        self.dataType = dataType
    }
}



let dummyScreenLayout = ScreenLayout(dataRows: [row1, row2, row3, row4, row5])
let row1 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .map)], size: 3)
let row2 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .time),
                                     LayoutDataItem(dataType: .distance)], size: 1)
let row3 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .speed),
                                     LayoutDataItem(dataType: .cadence)], size: 2)
let row4 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .power),
                                    LayoutDataItem(dataType: .threeSecondPower)], size: 1)
let row5 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .heartRate),
                                    LayoutDataItem(dataType: .grade)], size: 1)

let dataScreenLayout2 = ScreenLayout(dataRows: [screen2Row1, screen2Row2, screen2Row3, screen2Row4])
let screen2Row1 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .lapTime), LayoutDataItem(dataType: .lapPower)], size: 2)
let screen2Row2 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .threeSecondPower)], size: 1)
let screen2Row3 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .cadence),
                                            LayoutDataItem(dataType: .heartRate)], size: 1)
let screen2Row4 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .grade)], size: 2)

let dataScreenLayout3 = ScreenLayout(dataRows: [screen3Row1, screen3Row2, screen3Row3, screen3Row4])
let screen3Row1 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .interval)], size: 3)
let screen3Row2 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .cadence),
                                            LayoutDataItem(dataType: .heartRate)], size: 1)
let screen3Row3 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .lapTime),
                                            LayoutDataItem(dataType: .lapPower)], size: 1)
let screen3Row4 = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .altitude),
                                            LayoutDataItem(dataType: .elevationGain)], size: 1)
