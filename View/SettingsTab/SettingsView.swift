//
//  SettingsView.swift
//  SettingsView
//
//  Created by Allen Liang on 8/31/21.
//

import SwiftUI


struct SettingsView: View {
    @State var autoPause: Bool = Profile.default.autoPause
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // TESTING
                    FormLinkView(name: "Sensors", destination: AnyView(SensorSettingsView()))
                    FormLinkView(name: "Routes", destination: AnyView(RoutesSettingView()))
                    FormLinkView(name: "Stats", destination: AnyView(StatsSettingView()))
                    ScreenLayoutRowView()
                    FormLinkView(name: "Integrations", destination: AnyView(IntegrationsView()))
                    
                }
                Section(header: Text("Ride Configuration")) {
                    Toggle(isOn: $autoPause) {
                        Text("Auto Pause")
                            .font(.system(size: 20))
                    }
                    .onChange(of: autoPause) { value in
                        Profile.default.setAutoPauseSetting(value: value)
                    }
                }
                
            }
            .navigationBarTitle(Text("Settings"))
            .font(.largeTitle)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}











