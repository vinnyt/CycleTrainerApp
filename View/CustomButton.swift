//
//  CustomButton.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/14/21.
//

import SwiftUI

struct CustomButton: View {
    var text: String
    var textColor: Color = .white
    var action: (() -> Void)
    var fontSize: CGFloat = 20
    var backgroundColor = Color.orange
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: fontSize))
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(8)
        }
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(text: "Start", action: { print("hello") })
    }
}
