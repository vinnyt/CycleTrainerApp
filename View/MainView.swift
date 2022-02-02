//
//  MainView.swift
//  MainView
//
//  Created by Allen Liang on 8/31/21.
//

import SwiftUI

struct MainView: View {
    @StateObject var globalState = GlobalObject.shared
    @StateObject var viewModel = PeripheralViewModel()
    @StateObject var historyViewModel = HistoryViewModel()
    @State private var tabSelection = 1
    @State private var firstTabTappedTwice = false
    @State private var secondTabTappedTwice = false
    @State private var thirdTabTappedTwice = false
    @State private var computerTabUUID = UUID()
    @State private var historyTabUUID = UUID()
    @State private var settingsTabUUID = UUID()
    
    var body: some View {
        
        var handler: Binding<Int> { Binding(
            get: { self.tabSelection },
            set: {
                if $0 == self.tabSelection {
                    // Lands here if user tapped more than once
                    print(type(of: $0))
                    switch $0 {
                    case 1:
                        firstTabTappedTwice = true
                    case 2:
                        secondTabTappedTwice = true
                    case 3:
                        thirdTabTappedTwice = true
                    default:
                        print("default case tab view")
                    }
                }
                self.tabSelection = $0
            }
        )}
        
        return TabView(selection: handler) {
            DataScreenView(dataScreenViewModel: DataScreenViewModel())
                .tabItem {
                    Label("Computer", systemImage: "iphone")
                }
                .environmentObject(viewModel)
                .id(computerTabUUID)
                .tag(1)
                .onChange(of: firstTabTappedTwice) { _ in
                    guard firstTabTappedTwice else { return }
                    computerTabUUID = UUID()
                    firstTabTappedTwice = false
                }
            
            HistoryView(viewModel: historyViewModel)
                .tabItem {
                    Label("History", systemImage: "text.justify")
                }
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, PersistenceContainer.shared.container.viewContext)
                .id(historyTabUUID)
                .tag(2)
                .onChange(of: secondTabTappedTwice) { _ in
                    guard secondTabTappedTwice else { return }
                    historyTabUUID = UUID()
                    secondTabTappedTwice = false
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, PersistenceContainer.shared.container.viewContext)
                .id(settingsTabUUID)
                .tag(3)
                .onChange(of: thirdTabTappedTwice) { _ in
                    guard thirdTabTappedTwice else { return }
                    settingsTabUUID = UUID()
                    thirdTabTappedTwice = false
                }
        }
        .environmentObject(globalState)
        .hud(isPresented: $globalState.hudIsPresented) {
            Label(globalState.hudMessage, systemImage: globalState.hudSystemImage)
                .foregroundColor(.black)
        }
        .onAppear {
            print(UserDefaults.standard.string(forKey: StravaKeys.accessToken.rawValue))
        }
    }
}
