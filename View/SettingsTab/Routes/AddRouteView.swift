//
//  AddRouteView.swift
//  AddRouteView
//
//  Created by Allen Liang on 9/18/21.
//

import SwiftUI

struct AddRouteView: View {
    @Binding var isPresented: Bool
    @State private var routeName: String = ""
    @State private var gpxXML: String = ""
    @State var fileUrl: URL?
    @State var showingDocumentPicker = false
    @State private var showingRouteNameAlert = false
    
    var body: some View {
        
        VStack {
            Form {
                HStack {
                    Text("Route Name: ")
                    TextField("Enter Route Name", text: $routeName)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("GPX File: ")
                        Text(fileUrl?.fileNameString ?? "No file selected")
                    }
                    
                    Button("Browse...") {
                        showingDocumentPicker.toggle()
                    }
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .buttonStyle(.plain)
                }
                
                HStack {
                    Spacer()
                    Button("Save") {
                    saveRoute()
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    Spacer()
                }
                    
            }
            
            
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(fileUrl: $fileUrl)
        }
        .alert("Enter a name for your route", isPresented: $showingRouteNameAlert) {
            Button("OK", role: .cancel) {}
        }

    }
    
    func saveRoute() {
        if fileUrl != nil {
            if routeName == "" {
                showingRouteNameAlert = true
                return
            }
            let gpxParser = GPXParser(url: fileUrl!)
            let viewContext = PersistenceContainer.shared.container.viewContext

            let savedRoute = SavedRoute(context: viewContext)
            savedRoute.name = routeName
            savedRoute.locationData = gpxParser.locationData
            try? viewContext.save()
            isPresented.toggle()
        }
    }
    
}

struct AddRouteView_Previews: PreviewProvider {
    static var previews: some View {
        AddRouteView(isPresented: .constant(true))
    }
}

extension URL {
    var fileNameString: String {
        let string = self.absoluteString
        guard var index = string.lastIndex(of: "/") else { return string}
        index = string.index(after: index)
        
        let subString = string[index...]
        let fileNameString = String(subString)
        return fileNameString
    }
}
