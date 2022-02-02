//
//  RoutesSettings.swift
//  RoutesSettings
//
//  Created by Allen Liang on 9/17/21.
//

import SwiftUI
import CoreLocation

struct RoutesSettingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [])
    private var savedRoutes: FetchedResults<SavedRoute>
    @State var showingAddRoute = false
    
    var body: some View {
        List {
            if savedRoutes.count == 0 {
                HStack {
                    Spacer()
                    Text("No Routes")
                    .font(.title)
                    .bold()
                    Spacer()
                }
            }
            
            ForEach(savedRoutes, id: \.self) { savedRoute in
                NavigationLink(destination: RouteView(savedRoute: savedRoute)) {
                    RouteRowView(savedRoute: savedRoute)
                }
            }
            .onDelete(perform: deleteActivity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: {
                showingAddRoute.toggle()
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddRoute) {
            AddRouteView(isPresented: $showingAddRoute)
        }
    }
    
    private func deleteActivity(offsets: IndexSet) {
        offsets.map { savedRoutes[$0]}.forEach(viewContext.delete)
        try? viewContext.save()
        
    }
}

struct RouteView: View {
    @EnvironmentObject var viewModel: PeripheralViewModel
    var savedRoute: SavedRoute
    
    var body: some View {
        MapView(coordinates: savedRoute.coordinates)
            .toolbar {
                Button(action: {
                    if viewModel.savedRoute == savedRoute {
                        viewModel.savedRoute = nil
                        notifyRouteDidChange(coordinates: nil)
                    } else {
                        viewModel.savedRoute = savedRoute
                        notifyRouteDidChange(coordinates: savedRoute.coordinates)
                    }
                    
                }) {
                    if savedRoute == viewModel.savedRoute {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(savedRoute.name)
    }
    
    func notifyRouteDidChange(coordinates: [CLLocationCoordinate2D]?) {
        let userInfo = [
            "coordinates": coordinates
        ]
        NotificationCenter.default.post(name: NSNotification.Name("routeDidChange"), object: nil ,userInfo: userInfo)
    }
}

struct RouteRowView: View {
    var savedRoute: SavedRoute
    
    var body: some View {
        Text(savedRoute.name)
    }
}
