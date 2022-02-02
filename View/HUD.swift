//
//  HUD.swift
//  BikeComputer
//
//  Created by Allen Liang on 11/17/21.
//

import SwiftUI

struct HUD<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    content
      .padding(.horizontal, 12)
      .padding(16)
      .background(
        Capsule()
          .foregroundColor(Color.white)
          .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
      )
  }
}

extension View {
    func hud<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .top) {
            self
            
            if isPresented.wrappedValue {
                HUD(content: content)
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }
    
    func loadingIndicator(isPresented: Binding<Bool>) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                Color.black.opacity(0.55).ignoresSafeArea(.all)
                LoadingView()
                    .zIndex(1)
            }
        }
        .animation(.default, value: isPresented.wrappedValue)
    }
    
    func successIndicator(isPresented: Binding<Bool>) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                Color.black.opacity(0.55).ignoresSafeArea(.all)
                SuccessView()
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isPresented.wrappedValue = false
                        }
                    }
                    .zIndex(1)
                    
            }
        }
        .animation(.default, value: isPresented.wrappedValue)
    }
}

struct SuccessView: View {
    
    var body: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 120, height: 120)
            .cornerRadius(25)
            .overlay(content: {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 50, height: 50)
            })
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            SuccessView()
        }
    }
}
