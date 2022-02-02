//
//  ScreenLayoutRowView.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/5/21.
//

import Foundation
import SwiftUI

struct ScreenLayoutRowView: View {
    @State var showAlert = false // change name
    
    var body: some View {
//        return NavigationLink(destination: ScreenLayoutSettings()) {
            HStack(spacing: 16) {
                Text("Data Screen Layout")
                    .font(.system(size: 20))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showAlert = true
            }
            .fullScreenCover(isPresented: $showAlert) {
                DataScreenLayoutEditor()
                    .environmentObject(DataScreenLayoutEditorViewModel())
            }
        //        }
    }
}

struct ScreenLayoutSettings: View {
    @State var showEditScreen = false
    
    var body: some View {
        Form {
            Text("Data Screen 1")
                .onTapGesture {
                    showEditScreen = true
                }
        }
        .fullScreenCover(isPresented: $showEditScreen) {
            EditScreenLayoutView(isPresented: $showEditScreen)
        }
        .navigationTitle("Data Screen Layout")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScreenLayoutSettings_Previews: PreviewProvider {
    static var previews: some View {
        ScreenLayoutSettings()
    }
}

struct EditScreenLayoutView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Editing: Layout 1")
            Divider()
            Spacer()
            
            HStack(spacing: 0) {
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .font(Font.body.bold())
                }
                
                Button(action: {
                    print("save")
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .font(Font.body.bold())
                }
            }
            .ignoresSafeArea()
            .frame(height: 40)
            
        }
    }
}
