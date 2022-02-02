//
//  Utility.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/5/21.
//

import Foundation
import SwiftyXML

class Utility {
    static func getDataValueString(value: Any?, dataType: DataType) -> (String, String) {
        switch dataType {
        case .power:
            let power = value as? Int ?? 999
            return ("\(power)", "w")
        case .heartRate:
            let heartRate = value as? Int ?? 999
            return ("\(heartRate)", "bpm")
        case .cadence:
            let cadence = value as? Int ?? 999
            return ("\(cadence)", "rpm")
        case .speed:
            let speed = value as? Double ?? 99.99
            return (String(format: "%.1f", speed), "mph")
        case .time:
            let time = value as? Int ?? 999
            return (timeString(seconds: time), "")
        case .distance:
            let distance = value as? Double ?? 999
            return (String(format: "%.2f", distance), "mi")
        case .threeSecondPower:
            let threeSecondPower = value as? Int ?? 999
            return ("\(threeSecondPower)", "w")
        case .lapTime:
            let lapTime = value as? Int ?? 999
            return (timeString(seconds: lapTime), "")
        case .lapPower:
            let lapPower = value as? Int ?? 999
            return ("\(lapPower)", "w")
        case .grade:
            let grade = value as? Int ?? 999
            return ("\(grade)", "%")
        case .altitude:
            let altitude = value as? Double ?? 99.99
            return ("\(Int(altitude))", "ft")
        case .elevationGain:
            let elevationGain = value as? Double ?? -1
            return ("\(Int(elevationGain))", "ft")
        case .avgSpeed:
            let avgSpeed = value as? Double ?? -1.0
            return (String(format: "%.1f", avgSpeed), "mph")
        case .avgHeartRate:
            let avgHeartRate = value as? Int ?? -1
            return ("\(avgHeartRate)", "bpm")
        case .avgPower:
            let avgPower = value as? Int ?? -1
            return ("\(avgPower)", "w")
        default:
            return ("","")
        }
    }
    
    static func metersToFeet(meters: Double) -> Double {
        return meters * 3.281
    }
    
    static func utcString(from date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        df.timeZone = TimeZone(abbreviation: "UTC")
        return df.string(from: date)
    }
    
    static func generateGpxUrl(savedActivity: NewSavedActivity) -> URL {
        let hasHeartRate = savedActivity.avgHeartRate > 0
        let hasPower = savedActivity.avgPower > 0
        let hasCadence = savedActivity.avgCadence > 0
        
        let trackPoints = savedActivity.trackPoints
        let gpx = XML(name: "gpx")
            .addAttributes([
                "creator": "StravaGPX",
                "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
                "xsi:schemaLocation": "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd",
                "version": "1.1",
                "xmlns": "http://www.topografix.com/GPX/1/1",
                "xmlns:gpxtpx": "http://www.garmin.com/xmlschemas/TrackPointExtension/v1",
                "xmlns:gpxx": "http://www.garmin.com/xmlschemas/GpxExtensions/v3"
            ])
        
        let metadata = XML(name: "metadata")
        let time = XML(name: "time")
        let startDate = savedActivity.startDate
        time.value = Utility.utcString(from: startDate)
        metadata.addChild(time)
        gpx.addChild(metadata)
        
        let trk = XML(name: "trk")
        let name = XML(name: "name")
        name.value = "Ride"
        
        let type = XML(name: "type")
        type.value = "1"
        
        trk.addChild(name)
        trk.addChild(type)
        
        let trkseg = XML(name: "trkseg")
        
        for trackPoint in trackPoints {
            if let lat = trackPoint.latitude, let lon = trackPoint.longitude {
                let trkpt = XML(name: "trkpt").addAttributes([
                    "lat": "\(lat)",
                    "lon": "\(lon)"
                ])
                
                let timeStamp = XML(name: "time")
                timeStamp.value = Utility.utcString(from: trackPoint.timeStamp)
                
                trkpt.addChild(timeStamp)
                
                let extensions = XML(name: "extensions")
                
                if hasPower {
                    if let power = trackPoint.power {
                        let powerXML = XML(name: "power")
                        powerXML.value = "\(power)"
                        extensions.addChild(powerXML)
                    }
                }
                
                let gpxtpx = XML(name: "gpxtpx:TrackPointExtension")
                
                if hasHeartRate {
                    if let hr = trackPoint.heartRate {
                        let hrXML = XML(name: "gpxtpx:hr")
                        hrXML.value = "\(hr)"
                        gpxtpx.addChild(hrXML)
                    }
                }
                
                if hasCadence {
                    if let cadence = trackPoint.cadence {
                        let cadenceXML = XML(name: "gpxtpx:cad")
                        cadenceXML.value = "\(cadence)"
                        gpxtpx.addChild(cadenceXML)
                    }
                }
               
                extensions.addChild(gpxtpx)
                trkpt.addChild(extensions)
                trkseg.addChild(trkpt)
            } else {
                continue
            }
        }
        
        trk.addChild(trkseg)
        gpx.addChild(trk)
        
        let xmlData = gpx.toXMLString().data(using: .utf8)
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent("export.gpx")
        
        do {
            try xmlData?.write(to: url, options: .atomic)
        } catch {
            print("error writing gpx to url", error)
        }
        return url
    }
    
    static func calculateRpm(prevRev: UInt16, prevTime: UInt16, rev: UInt16, time: UInt16) -> Int {
        let totalRevs: UInt16 = rev &- prevRev
        let timeElapsed: UInt16 = time &- prevTime // time resolution is 1/1024s
        
        print("total revs: \(totalRevs)")
        print("timeelasped: \(timeElapsed)")
        if timeElapsed == 0 {
             return 0
        }
        
        let i = 61440 / Int(timeElapsed) // 61440 = 60 * 1024 to convert to revolutions per minute
        let rpm = Int(totalRevs) * i
        
        return rpm
    }
    
    static func calculateRpm(prevRev: UInt32, prevTime: UInt16, rev: UInt32, time: UInt16) -> Int {
        let totalRevs: UInt32 = rev &- prevRev
        let timeElapsed: UInt16 = time - prevTime // time resolution is 1/1024s
        
        let i = 61440 / Int(timeElapsed) // 61440 = 60 * 1024 to convert to revolutions per minute
        let rpm = Int(totalRevs) * i
        
        return rpm
    }
    
    static func uInt8ToUint16(_ byte1: UInt8, _ byte2: UInt8) -> UInt16 {
        return (UInt16(byte1) | (UInt16(byte2) << 8))
    }
    
    static func uInt8ToUInt32(_ byte1: UInt8, byte2: UInt8, byte3: UInt8, byte4: UInt8) -> UInt32 {
        return (UInt32(byte1) | (UInt32(byte2) << 8) | (UInt32(byte3) << 16) | (UInt32(byte4) << 24))
    }
}
