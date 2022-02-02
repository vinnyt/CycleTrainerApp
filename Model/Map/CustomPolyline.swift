//
//  CustomPolyLine.swift
//  CustomPolyLine
//
//  Created by Allen Liang on 9/20/21.
//

import Foundation
import MapKit

//final class CustomPolyline: MKPolyline {
//    var strokeColor: UIColor
//    var lineWidth: CGFloat
//
//    init(coordinates: [CLLocationCoordinate2D], strokeColor: UIColor, lineWidth: CGFloat) {
//        self.strokeColor = strokeColor
//        self.lineWidth = lineWidth
////        super.init()
//        super.init(coordinates: coordinates, count: coordinates.count)
//
//    }
//
//    convenience init(coordinates: [CLLocationCoordinate2D], strokeColor: UIColor, lineWidth: CGFloat) {
//        self.init(coordinates: coordinates)
//        self.strokeColor = strokeColor
//        self.lineWidth = lineWidth
//
//    }
//
//
//}

final class CustomPolyline: MKPolyline {
    var color: UIColor?
    var width: CGFloat?
    
    convenience init(coordinates: [CLLocationCoordinate2D], color: UIColor, width: CGFloat) {
        self.init(coordinates: coordinates, count: coordinates.count)
        self.color = color
        self.width = width
    }
}
