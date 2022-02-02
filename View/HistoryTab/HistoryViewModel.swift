//
//  HistoryViewModel.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/4/21.
//

import Foundation
import CoreData
import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var savedActivities = [NewSavedActivity]()
    @Published var isLoading = false
    var perPage = 8
    var page = 0
    
    
    func loadSavedActivities() {
        checkIfNewActivityAdded()
        print("fetch")
//        print("page", page)
//        print(savedActivities.count)
        let moc = PersistenceContainer.shared.container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NewSavedActivity")
        request.fetchLimit = perPage
        request.fetchOffset = perPage * page
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        isLoading = true
        
        print("offset: ", request.fetchOffset)
        
        do {
            guard let fetchedActivities = try moc.fetch(request) as? [NewSavedActivity] else { return }
            print("fetched :",fetchedActivities.count)
                self.isLoading = false
                if fetchedActivities.count > 0 {
                    DispatchQueue.main.async {
                        self.savedActivities += fetchedActivities
                        self.page += 1
                    }
                    print(savedActivities.count)
                }
        } catch {
            print("error fetching activities: ", error)
        }
        
    }
    
    func checkIfNewActivityAdded() {
        if let currentFetchedDate = savedActivities.first?.startDate {
            let moc = PersistenceContainer.shared.container.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NewSavedActivity")
            request.fetchLimit = 1
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            do {
                if let fetchedActivities = try moc.fetch(request) as? [NewSavedActivity] {
                    if let newFetchDate = fetchedActivities.first {
                        if newFetchDate.startDate > currentFetchedDate {
                            self.page = 0
                            self.savedActivities = [NewSavedActivity]()
                            print("cleared")
                        }
                    }
                }
            } catch {
                print(error)
            }
        } else {
            self.page = 0
                self.savedActivities = [NewSavedActivity]()
            print("cleared")

        }
    }
    
    func refreshData() {
        page = 0
        savedActivities = [NewSavedActivity]()
        print("cleared")
        loadSavedActivities()
    }
    
    func remove(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        savedActivities.remove(at: index)
    }
}
