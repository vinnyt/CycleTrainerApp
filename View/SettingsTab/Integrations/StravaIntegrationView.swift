//
//  StravaIntegrationView.swift
//  BikeComputer
//
//  Created by Allen Liang on 12/2/21.
//

import SwiftUI

struct StravaIntegrationView: View {
    @ObservedObject var viewModel = StravaIntegrationViewModel()
    @State private var showSignInAlert = false
    @State private var showAllowAccessAlert = false
    @State private var disconnectStravaAlert = false
    @State private var showingErrorAlert = false
    var sidePadding: CGFloat = 40
    
    var body: some View {
        VStack {
            if !viewModel.authState {
                VStack(spacing: 16) {
                    Text("Upload activities to Strava?")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .bold))
                        .padding(.leading, sidePadding)
                        .padding(.trailing, sidePadding)
                    Text("This means data from CycleTrainer will be shared with Strava, which may include heart rate, power data, location and other related metrics.")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.leading, sidePadding)
                        .padding(.trailing, sidePadding)
                    Text("Do you authorize CycleTrainer to share this data with Strava? You can discontinue data sharing with Strava at any time in your CycleTrainer Settings.")
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.leading, sidePadding)
                        .padding(.trailing, sidePadding)
                    Button {
                        handleStravaAuth()
                    } label: {
                        Image("connect_with_strava")
                    }
                    
                    Spacer()
                }
                .padding(.top, 24)
            } else {
                VStack {
                    
                    HStack {
                        Text("SHARE ACTIVITY")
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Toggle("", isOn: $viewModel.shareActivity)
                            .onChange(of: viewModel.shareActivity) { newValue in
                                viewModel.setShareActivityState(state: newValue)
                            }
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                    .padding(.top, 24)
                    
                    Text("Automatically post your Activities to Strava upon completion. This will include heart rate, power, location and other related metrics. You can deactivate this at any time.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.leading, 24)
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    
                    Spacer()
                    Button("Disconnect") {
                        disconnectStravaAlert = true
                    }
                    .foregroundColor(.red)
                    .padding()
                    .padding(.bottom, 64)
                    .alert(isPresented: $showingErrorAlert) {
                        Alert(title: Text("An Error Occurred, please try again."), message: nil)
                    }
                    
                }
            }
            
        }
        .navigationTitle("Strava")
        .navigationBarTitleDisplayMode(.inline)
        .alert("CycleTrainer Wants to Use \"strava.com\" to Sign In", isPresented: $showSignInAlert, actions: {
            Button("Cancel") {}
            Button("Continue") {
                UIApplication.shared.open(StravaConfig.stravaAuthUrl, options: [:]) { success in
                    //handle error
                }
            }
        }, message: {
            Text("This allows the app and website to share information about you.")
        })
        .alert(isPresented: $showAllowAccessAlert) {
            Alert(title: Text("Please Allow Access"), message: Text("CycleTrainer needs access to your Strava Account to upload activities. Please enable the requested permissions."))
        }
        .alert("Disconnect Strava?", isPresented: $disconnectStravaAlert, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Disconnect", role: .destructive, action: {
                viewModel.disconnectStrava()
            })
        })
        .onOpenURL { url in // TODO: throw this in a function
            if !checkScope(url: url) {
                showAllowAccessAlert = true
                return
            }
            
            
            guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
            
            if let queryItems = urlComponents.queryItems {
                for query in queryItems {
                    if query.name == "code" {
                        let code = query.value ?? ""
                        StravaAPI.shared.requestAccessToken(code: code) { result in
                            switch result {
                            case .failure(_):
                                showingErrorAlert = true
                            case .success(_):
                                viewModel.setAuthState(state: true)
                                viewModel.setShareActivityState(state: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func checkScope(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
        if let queryItems = components.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "scope" {
                    let value = queryItem.value ?? ""
                    if value.contains("write") {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func handleStravaAuth() {
        let app = UIApplication.shared
        if app.canOpenURL(StravaConfig.stravaAuthUrlScheme) {
            app.open(StravaConfig.stravaAuthUrlScheme, options: [:]) { success in
                //successful
            }
        } else {
            //open safari
            showSignInAlert = true
            
        }
    }
}
