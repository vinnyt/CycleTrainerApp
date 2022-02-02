//
//  MapView.swift
//  MapView
//
//  Created by Allen Liang on 9/8/21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @EnvironmentObject var viewModel: PeripheralViewModel
    var coordinates: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        if coordinates.count > 1 {
            let latData = coordinates.map {$0.latitude}
            let lonData = coordinates.map {$0.longitude}
            
            let latitudeDelta = latData.max()! - latData.min()! + 0.01
            let longitudeDelta = lonData.max()! - lonData.min()! + 0.01
            
            let lowerCorner = CLLocationCoordinate2D(latitude: latData.min()!, longitude: lonData.min()!)
            let upperCorner = CLLocationCoordinate2D(latitude: latData.max()!, longitude: lonData.max()!)
            
            let centerCoordinate = calculateCenter(point1: lowerCorner, point2: upperCorner)
            
            
            let region = MKCoordinateRegion(center: centerCoordinate, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
            mapView.region = region
        }
        
        return mapView
    }
    
    
    func calculateCenter(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> CLLocationCoordinate2D{
        let lon1 = point1.longitude * Double.pi / 180
        let lon2 = point2.longitude * Double.pi / 180
        
        let lat1 = point1.latitude * Double.pi / 180
        let lat2 = point2.latitude * Double.pi / 180
        
        let dLon = lon2 - lon1
        
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        let centerLat = lat3 * 180 / Double.pi
        let centerLon = lon3 * 180 / Double.pi
        return CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
    }
    

    func updateUIView(_ view: MKMapView, context: Context) {

    }

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    
    var parent: MapView
    var undrawnLastCoordinate: CLLocationCoordinate2D?
    var isRouteOverlay = false
    

    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            lineRenderer.lineWidth = 3.0
            return lineRenderer
        }
        return MKPolylineRenderer()
    }
}
