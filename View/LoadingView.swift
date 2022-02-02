//
//  LoadingView.swift
//  BikeComputer
//
//  Created by Allen Liang on 11/29/21.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    
    var body: some View {
            VStack {
                ProgressView()
                    .scaleEffect(3)
                    .frame(width: 80, height: 80)
                    .tint(.black)
                
                Text("Please Wait...")
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .padding()
            .background(.white)
            .cornerRadius(25)
    }
}
