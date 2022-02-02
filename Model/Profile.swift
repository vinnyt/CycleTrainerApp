//
//  Profile.swift
//  Profile
//
//  Created by Allen Liang on 9/17/21.
//

import Foundation
import CoreData
import SwiftUI

class Profile {
    static let `default` = Profile()
    
    private(set) var autoPause = false
    var ftp: Int
    var isCalculatingBestPowers = false
    var listeners = [ProfileObserver]()
    var dataScreens = [ScreenLayout]()
    
    var zones: [String: [Int]] {
        let zoneRanges = [[0,0.59], [0.60, 0.79], [0.80, 0.90], [0.91, 1.04], [1.05, 1.20], [1.21, 10]]
        var zones = [String: [Int]]()
        for i in 0...5 {
            let low = Int(Double(ftp) * zoneRanges[i][0])
            let high = Int(Double(ftp) * zoneRanges[i][1])
            zones["\(i + 1)"] = [low,high]
        }
        return zones
    }
    
    var bestPowers: [BestPowers: Int] = [
        .maxPower : 0,
        .fiveSecondPower : 0,
        .oneMinutePower : 0,
        .threeMinutePower : 0,
        .fiveMinutePower : 0,
        .tenMinutePower : 0,
        .twentyMinutePower : 0
    ]
    
    private init() {
        ftp = UserDefaults.standard.integer(forKey: "ftp")
        DispatchQueue.global(qos: .userInitiated).async {
            self.calculateBestPowers()
        }
        setupProfile()
    }
    
    func setupProfile() {
        autoPause = UserDefaults.standard.bool(forKey: "autoPause")

        if let dataScreenData = UserDefaults.standard.data(forKey: "dataScreens") {
            do {
                let dataScreens = try JSONDecoder().decode([ScreenLayout].self, from: dataScreenData)
                self.dataScreens = dataScreens
            } catch {
                print("error decoding screen layouts: ", error)
                self.dataScreens = [dummyScreenLayout, dataScreenLayout2, dataScreenLayout3]
            }
        } else {
            self.dataScreens = [dummyScreenLayout, dataScreenLayout2, dataScreenLayout3]
        }
        
    }
    
    func setDataScreen(dataScreens: [ScreenLayout]) {
        self.dataScreens = dataScreens
        notifyObserversDataScreensDidUpdate()
        //save
        do {
            let data = try JSONEncoder().encode(dataScreens)
            UserDefaults.standard.set(data, forKey: "dataScreens")
        } catch {
            print("error encoding data screens: ", error)
        }
    }
    
    func setAutoPauseSetting(value: Bool) {
        autoPause = value
        UserDefaults.standard.set(autoPause, forKey: "autoPause")
    }
    
    func deleteDataScreens() {
        self.dataScreens = [ScreenLayout]()
        notifyObserversDataScreensDidUpdate()
    }
    
    func addListener(listener: ProfileObserver) {
        listeners.append(listener)
    }
    
    func setFTP(ftp : Int) {
        self.ftp = ftp
        UserDefaults.standard.set(ftp, forKey: "ftp")
    }
    
    func notifyObserversDataScreensDidUpdate() {
        for listener in listeners {
            listener.profileDataScreensDidUpdate()
        }
    }
    
    func updateListeners() {
        for listener in listeners {
            listener.calculatingBestPowersDidUpdate()
        }
    }
    
    func calculateBestPowers() {
        let moc = PersistenceContainer.shared.container.viewContext
        let savedActivitiesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "NewSavedActivity")
        let dateLastCalculated = UserDefaults.standard.object(forKey: "dateBestPowersCalculated") as? Date
        
        if dateLastCalculated != nil {
            let predicate = NSPredicate(format: "startDate > %@", dateLastCalculated! as NSDate)
            savedActivitiesFetch.predicate = predicate
        }
        
        setBestPowers()
        
        do {
            if let savedActivities = try moc.fetch(savedActivitiesFetch) as? [NewSavedActivity] {
                //notify calculating
                isCalculatingBestPowers = true
                for savedActivity in savedActivities {
                    let power = analyzePowerData(trackPoints: savedActivity.trackPoints)
                    bestPowers[.maxPower] = power[.maxPower] ?? 0 > bestPowers[.maxPower] ?? 0 ? power[.maxPower] ?? 0 : bestPowers[.maxPower]
                    bestPowers[.fiveSecondPower] = power[.fiveSecondPower] ?? 0 > bestPowers[.fiveSecondPower] ?? 0 ? power[.fiveSecondPower] ?? 0 : bestPowers[.fiveSecondPower]
                    bestPowers[.oneMinutePower] = power[.oneMinutePower] ?? 0 > bestPowers[.oneMinutePower] ?? 0 ? power[.oneMinutePower] ?? 0 : bestPowers[.oneMinutePower]
                    bestPowers[.threeMinutePower] = power[.threeMinutePower] ?? 0 > bestPowers[.threeMinutePower] ?? 0 ? power[.threeMinutePower] ?? 0 : bestPowers[.threeMinutePower]
                    bestPowers[.fiveMinutePower] = power[.fiveMinutePower] ?? 0 > bestPowers[.fiveMinutePower] ?? 0 ? power[.fiveMinutePower] ?? 0 : bestPowers[.fiveMinutePower]
                    bestPowers[.tenMinutePower] = power[.tenMinutePower] ?? 0 > bestPowers[.tenMinutePower] ?? 0 ? power[.tenMinutePower] ?? 0 : bestPowers[.tenMinutePower]
                    bestPowers[.twentyMinutePower] = power[.twentyMinutePower] ?? 0 > bestPowers[.twentyMinutePower] ?? 0 ? power[.twentyMinutePower] ?? 0 : bestPowers[.twentyMinutePower]
                    print(savedActivity.startDate)
                }
                UserDefaults.standard.set(bestPowers[.maxPower], forKey: BestPowers.maxPower.rawValue)
                UserDefaults.standard.set(bestPowers[.fiveSecondPower], forKey: BestPowers.fiveSecondPower.rawValue)
                UserDefaults.standard.set(bestPowers[.oneMinutePower], forKey: BestPowers.oneMinutePower.rawValue)
                UserDefaults.standard.set(bestPowers[.threeMinutePower], forKey: BestPowers.threeMinutePower.rawValue)
                UserDefaults.standard.set(bestPowers[.fiveMinutePower], forKey: BestPowers.fiveMinutePower.rawValue)
                UserDefaults.standard.set(bestPowers[.tenMinutePower], forKey: BestPowers.tenMinutePower.rawValue)
                UserDefaults.standard.set(bestPowers[.twentyMinutePower], forKey: BestPowers.twentyMinutePower.rawValue)
                UserDefaults.standard.set(Date(), forKey: "dateBestPowersCalculated")
                isCalculatingBestPowers = false
                updateListeners()
                //notify done calculating
            }
        } catch {
            print(error)
        }
    }
    
    func setBestPowers() {
        self.bestPowers[.maxPower] = UserDefaults.standard.integer(forKey: BestPowers.maxPower.rawValue)
        self.bestPowers[.fiveSecondPower] = UserDefaults.standard.integer(forKey: BestPowers.fiveSecondPower.rawValue)
        self.bestPowers[.oneMinutePower] = UserDefaults.standard.integer(forKey: BestPowers.oneMinutePower.rawValue)
        self.bestPowers[.threeMinutePower] = UserDefaults.standard.integer(forKey: BestPowers.threeMinutePower.rawValue)
        self.bestPowers[.fiveMinutePower] = UserDefaults.standard.integer(forKey: BestPowers.fiveMinutePower.rawValue)
        self.bestPowers[.tenMinutePower] = UserDefaults.standard.integer(forKey: BestPowers.tenMinutePower.rawValue)
        self.bestPowers[.twentyMinutePower] = UserDefaults.standard.integer(forKey: BestPowers.twentyMinutePower.rawValue)
    }
    
    func analyzePowerData(trackPoints: [TrackPoint]) -> [BestPowers: Int] {
        var powers = [BestPowers: Int]()
        let powerData = trackPoints.map {  $0.power != nil ? $0.power! : 0 }
        //Max Power
        var maxPower = 0
        for i in 0 ..< powerData.count {
            maxPower = powerData[i] > maxPower ? powerData[i] : maxPower
        }
        powers[.maxPower] = maxPower
        
        var durationSeconds = 0
        
        
        //5 second Power
        var bestFiveSecondPower = 0
        durationSeconds = 5
        for i in 0 ..< powerData.count {
            if i <= powerData.count - durationSeconds {
                var sum = 0
                for j in i ..< i + durationSeconds {
                    sum += powerData[j]
                }
                let power = sum / durationSeconds
                bestFiveSecondPower = power > bestFiveSecondPower ? power : bestFiveSecondPower
            }
        }
        powers[.fiveSecondPower] = bestFiveSecondPower
        
        //1 minute power
        var bestOneMinutePower = 0
        durationSeconds = 60
        for i in 0 ..< powerData.count {
            if i <= powerData.count - durationSeconds {
                var sum = 0
                for j in i ..< i + durationSeconds {
                    sum += powerData[j]
                }
                let power = sum / durationSeconds
                bestOneMinutePower = power > bestOneMinutePower ? power : bestOneMinutePower
            } else {
                break
            }
        }
        powers[.oneMinutePower] = bestOneMinutePower
        
        //3 minute power
        var bestThreeMinutePower = 0
        durationSeconds = 180
        for i in 0 ..< powerData.count {
            if i <= powerData.count - durationSeconds {
                var sum = 0
                for j in i ..< i + durationSeconds {
                    sum += powerData[j]
                }
                let power = sum / durationSeconds
                bestThreeMinutePower = power > bestThreeMinutePower ? power : bestThreeMinutePower
            } else {
                break
            }
        }
        powers[.threeMinutePower] = bestThreeMinutePower
        
        //5 minute power
        var bestFiveMinutePower = 0
        durationSeconds = 300
        for i in 0 ..< powerData.count {
            if i <= powerData.count - durationSeconds {
                var sum = 0
                for j in i ..< i + durationSeconds {
                    sum += powerData[j]
                }
                let power = sum / durationSeconds
                bestFiveMinutePower = power > bestFiveMinutePower ? power : bestFiveMinutePower
            } else {
                break
            }
        }
        powers[.fiveMinutePower] = bestFiveMinutePower
        
        //10 minute power
        var bestTenMinutePower = 0
        durationSeconds = 600
        for i in 0 ..< powerData.count {
            if i <= powerData.count - durationSeconds {
                var sum = 0
                for j in i ..< i + durationSeconds {
                    sum += powerData[j]
                }
                let power = sum / durationSeconds
                bestTenMinutePower = power > bestTenMinutePower ? power : bestTenMinutePower
            } else {
                break
            }
        }
        powers[.tenMinutePower] = bestTenMinutePower
        
        //20 minute power
        var bestTwentyMinutePower = 0
        durationSeconds = 1200
        for i in 0 ..< powerData.count {
            if i <= powerData.count - durationSeconds {
                var sum = 0
                for j in i ..< i + durationSeconds {
                    sum += powerData[j]
                }
                let power = sum / durationSeconds
                bestTwentyMinutePower = power > bestTwentyMinutePower ? power : bestTwentyMinutePower
            } else {
                break
            }
        }
        powers[.twentyMinutePower] = bestTwentyMinutePower
        
        return powers
    }
    
    
}

enum BestPowers: String {
    case maxPower = "maxPower"
    case fiveSecondPower = "fiveSecondPower"
    case oneMinutePower = "oneMinutePower"
    case threeMinutePower = "threeMinutePower"
    case fiveMinutePower = "fiveMinutePower"
    case tenMinutePower = "tenMinutePower"
    case twentyMinutePower = "twentyMinutePower"
}

protocol ProfileObserver {
    func calculatingBestPowersDidUpdate()
    func profileDataScreensDidUpdate()
}

extension ProfileObserver {
    func calculatingBestPowersDidUpdate() {}
    func profileDataScreensDidUpdate() {}
}


