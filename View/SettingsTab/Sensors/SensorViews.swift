//
//  SensorViews.swift
//  SensorViews
//
//  Created by Allen Liang on 9/17/21.
//

import SwiftUI

struct SensorSettingsView: View {
    
    var body: some View {
        Form {
            Section {
//                SystemLabelFormLinkView(name: "Heart Rate", systemName: "heart", destination: .init(HeartRateSensorSettings()))
//                LabelFormLinkView(name: "Power Meter", ImageName: "dumbbell", destination: .init(PowerMeterSensorSettings()))
//                SystemLabelFormLinkView(name: "Speed", systemName: "speedometer", destination: .init(SpeedSensorSetting()))
//                FormLinkView(name: "Cadence", destination: .init(CadenceSensorSetting()))
                
                FormLinkView(name: "Heart Rate", destination: .init(HeartRateSensorSettings()))
                FormLinkView(name: "Power Meter", destination: .init(PowerMeterSensorSettings()))
                FormLinkView(name: "Speed",  destination: .init(SpeedSensorSetting()))
                FormLinkView(name: "Cadence", destination: .init(CadenceSensorSetting()))
                
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
