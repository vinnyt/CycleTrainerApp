//
//  ActivitySummaryViewModel.swift
//  BikeComputer
//
//  Created by Allen Liang on 12/8/21.
//

import Foundation
import SwiftUI

class ActivitySummaryViewModel: ObservableObject {
    @Published var uploadToStrava: Bool = false
    @Published var isLoading = false
    @Published var authState: Bool
    @Published var showingAlert = false
    var alertMessage = ""
    
    init() {
        self.uploadToStrava = UserDefaults.standard.bool(forKey: StravaKeys.shareActivity.rawValue)
        self.authState = UserDefaults.standard.bool(forKey: StravaKeys.authState.rawValue)
    }
    
    func saveActivity(activity: Activity, presentationMode: Binding<PresentationMode>) {
        isLoading = true
        let savedActivity = activity.stopAndSaveActivity()
        if uploadToStrava && authState {
            let url = Utility.generateGpxUrl(savedActivity: savedActivity)
            StravaAPI.shared.uploadActivity(gpxURL: url) { result in
                self.dismissLoading()
                switch result {
                case .failure(let error):
                    self.showAlert(message: "Error uploading activity, please try again later.")
                    print(error)
                case .success(_):
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            dismissLoading()
            presentationMode.wrappedValue.dismiss()
        }
        
        
    }
    
    func dismissLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showingAlert = true
        }
    }
}
