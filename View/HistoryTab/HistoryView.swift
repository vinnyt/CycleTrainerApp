//
//  HistoryView.swift
//  HistoryView
//
//  Created by Allen Liang on 9/5/21.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.savedActivities.count == 0 {
                    HStack {
                        Spacer()
                        Text("No History")
                        .font(.title)
                        .bold()
                        Spacer()
                    }
                        
                }
                
                ForEach(viewModel.savedActivities, id: \.self) { savedActivity in
                    NavigationLink(destination: SummaryView(savedActivity: savedActivity)) {
                        HistorySavedActivityRowView(savedActivity: savedActivity)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            .onAppear {
                                if savedActivity == viewModel.savedActivities.last {
                                    loadMoreActivities()
                                }
                            }
                    }
                }
                .onDelete(perform: deleteActivity)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                }
            }
            .animation(.default, value: viewModel.savedActivities)
            .navigationTitle("History")
            .refreshable {
                viewModel.refreshData()

            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // i forget what this does
        .onAppear(perform: loadMoreActivities)
    }
    
    private func deleteActivity(offsets: IndexSet) {
        let viewContext = PersistenceContainer.shared.container.viewContext
        offsets.map { viewModel.savedActivities[$0]}.forEach(viewContext.delete)
        try? viewContext.save()
        viewModel.remove(at: offsets)

    }
    
    private func loadMoreActivities() {
        viewModel.loadSavedActivities()
    }
}

//struct HistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryView()
//    }
//}

struct HistorySavedActivityRowView: View {
    var savedActivity: NewSavedActivity
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(savedActivity.dateString)
                Text(String(format: "%.2f mi", savedActivity.distance))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(savedActivity.startTimeString)
                Text(savedActivity.durationString)
            }
        }
    }
}

