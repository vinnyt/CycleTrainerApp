//
//  IntegrationsView.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/22/21.
//

import SwiftUI

struct IntegrationsView: View {
    
    var body: some View {
        Form {
            FormLinkView(name: "Strava", destination: AnyView(StravaIntegrationView()))
        }
    }
}
