//
//  FormLinkView.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/22/21.
//

import SwiftUI

struct FormLinkView: View {
    var name: String
    var destination: AnyView
    
    var body: some View {
        return NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Text(name)
                    .font(.system(size: 20))
                    .frame(width: 150,height: 40, alignment: .leading)
            }
        }
    }
}

struct SystemLabelFormLinkView: View {
    var name: String
    var systemName: String
    var destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Label {
                    Text(name)
                        .font(.system(size: 20))
                        .frame(width: 150,height: 40, alignment: .leading)
                } icon: {
                    Image(systemName: systemName)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(uiColor: .label))
                }
            }
        }
    }
}

struct LabelFormLinkView: View {
    var name: String
    var ImageName: String
    var destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Label {
                    Text(name)
                        .font(.system(size: 20))
                        .frame(width: 150,height: 40, alignment: .leading)
                } icon: {
                    Image(ImageName)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color(uiColor: .label))
                }
            }
        }
    }
}
