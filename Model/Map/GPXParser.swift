//
//  GPXParser.swift
//  GPXParser
//
//  Created by Allen Liang on 9/9/21.
//

import Foundation
import CoreLocation

class GPXParser: NSObject, XMLParserDelegate {
    
    var locationData = [CLLocation]()
    
    init(gpxString: String) {
        super.init()
        let parser = XMLParser(data: gpxString.data(using: .utf8)!)
        parser.delegate = self
        print(parser.parse())
    }
    
    init(url: URL) {
        super.init()
        let parser = XMLParser(contentsOf: url)
        parser?.delegate = self
        print(parser?.parse())
    }
    
    override init() {
        super.init()
        if let path = Bundle.main.url(forResource: "route", withExtension: "gpx") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                if !parser.parse() {
                    print(parser.parserError)
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "trkpt" {
            if let lat = attributeDict["lat"], let lon = attributeDict["lon"] {
                
                let location = CLLocation(latitude: Double(lat)!, longitude: Double(lon)!)
                locationData.append(location)
            }
        }
    }
}
