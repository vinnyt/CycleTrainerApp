//
//  ActivityMapView.swift
//  ActivityMapView
//
//  Created by Allen Liang on 9/20/21.
//

import SwiftUI
import MapKit

struct ActivityMapView: UIViewRepresentable {
    @EnvironmentObject var viewModel: PeripheralViewModel
    @Binding var lockMap: Bool
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        viewModel.currentActivityMap.lockMap = lockMap
    }
    
    func makeUIView(context: Context) -> some MKMapView {
        return viewModel.currentActivityMap.mapView
    }
}
