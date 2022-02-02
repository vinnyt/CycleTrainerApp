//
//  CustomTabIndicator.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/19/21.
//

import SwiftUI

struct CustomTabIndicator: View {
    var count: Int
    @Binding var current: Int
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                
                ZStack {
                    if current == index {
                        Rectangle()
                            .fill(colorScheme  == .dark ? Color.white : Color .black)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                    }
                }
                .frame(width: 16, height: 4)
            }
        }
    }
}
