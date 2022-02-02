//
//  ActivityMap.swift
//  ActivityMap
//
//  Created by Allen Liang on 9/17/21.
//

import Foundation
import MapKit

class ActivityMap: NSObject, MKMapViewDelegate {
    
    var mapView: MKMapView
    var undrawnLastLocation: CLLocation?
    var initialRegionSet = false
    var lockMap = false
    var routeOverlay: CustomPolyline?
    var currentHeading: CLHeading = CLHeading()
    var currentRoutePolylines = [CustomPolyline]()
    var draw = false
    
    override init() {
        mapView = MKMapView()
        super.init()
        mapView.delegate = self
        mapView.showsUserLocation = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteDidChange), name: NSNotification.Name("routeDidChange"), object: nil)
    }
    
    @objc func handleRouteDidChange(_ notification: NSNotification) {
        if let routeOverlay = routeOverlay {
            mapView.removeOverlay(routeOverlay)
        }
        if let coordinates = notification.userInfo?["coordinates"] as? [CLLocationCoordinate2D] {
            drawRoute(coordinates: coordinates)
        }
    }
    
    func drawRoute(coordinates: [CLLocationCoordinate2D]) {
        let polyline = CustomPolyline(coordinates: coordinates, color: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), width: 3.0)
        routeOverlay = polyline
        mapView.addOverlay(polyline)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? CustomPolyline {
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = polyline.color
            lineRenderer.lineWidth = polyline.width ?? 3.0
            return lineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !initialRegionSet || lockMap {
            self.mapView.camera.centerCoordinate = userLocation.coordinate
            self.mapView.camera.centerCoordinateDistance = 1000
            initialRegionSet = true
        }
    }
    
    func clearCurrentPolylines() {
        for polyline in currentRoutePolylines {
            mapView.removeOverlay(polyline)
        }
    }
}

extension ActivityMap: LocationManagerObserver {
    func locationDidUpdate(location: CLLocation) {
        if !draw { return }
        if let undrawnLastLocation = undrawnLastLocation {
            let distanceBetweenLocations = location.distance(from: undrawnLastLocation)
            if distanceBetweenLocations > 10 {
                let polyline = CustomPolyline(coordinates: [undrawnLastLocation.coordinate, location.coordinate], color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), width: 3.0)
                mapView.addOverlay(polyline)
                currentRoutePolylines.append(polyline)
                self.undrawnLastLocation = location
            }
        } else {
            self.undrawnLastLocation = location
        }
    }
    // TODO: reduce energy usage
    func headingDidUpdate(newHeading: CLHeading) {
        if lockMap {
            let oldCamera = mapView.camera
            let newCamera = MKMapCamera(lookingAtCenter: oldCamera.centerCoordinate, fromDistance: oldCamera.centerCoordinateDistance, pitch: oldCamera.pitch, heading: newHeading.trueHeading) // TODO: refactor
            mapView.setCamera(newCamera, animated: true)
            currentHeading = newHeading
        }
    }
}
