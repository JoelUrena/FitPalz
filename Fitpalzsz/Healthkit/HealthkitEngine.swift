//
//  HealthkitEngine.swift
//  FitPalz Swift Edition
//
//  Created by Brian Arias Cano on 3/9/25.
//

import Foundation
import HealthKit

class HealthkitEngine: ObservableObject {
    
    //set this as the state object in the view
    static let shared = HealthkitEngine()
    var healthStore: HKHealthStore = HKHealthStore()
    
    //this is to update the view
    @Published var stepCount: Int = 0
    @Published var lifeTimeStepCount: Int = 0
    @Published var caloriesBurned: Double = 0.0
    @Published var walkingRunningDistance: Double = 0.0
    @Published var lifetimeDistance: Double = 0.0
    
    func readStepCountToday() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        var dayBefore: Date {
            return Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            //all the healthkit stuff happens on a background thread. need to fix this.
            
            //changes must be published on the main thread. there has to be a better way to do this
            DispatchQueue.main.async {
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                self.stepCount = steps
            }
            
            
        }
        
            self.healthStore.execute(query)
    
    }
    
    func readLifetimeSteps() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        var dayBefore: Date {
            return Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: .distantPast)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            //all the healthkit stuff happens on a background thread. need to fix this.
            
            //changes must be published on the main thread. there has to be a better way to do this
            DispatchQueue.main.async {
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                self.lifeTimeStepCount = steps
            }
            
            
        }
        
            self.healthStore.execute(query)
    
    }
    
    
    func readCaloiresBurnedToday() {
        guard let caloriesBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: caloriesBurnedType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            //all the healthkit stuff happens on a background thread. need to fix this.
            
            //changes must be published on the main thread. there has to be a better way to do this
            DispatchQueue.main.async {
                let caloriesBurned = sum.doubleValue(for: HKUnit.largeCalorie())
                self.caloriesBurned = caloriesBurned
            }
            
        }
        
            self.healthStore.execute(query)
    }
    
    func readWalkingandRunningDistanceToday() {
        guard let walkingRunningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: walkingRunningType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            //all the healthkit stuff happens on a background thread. need to fix this.
            
            //changes must be published on the main thread. there has to be a better way to do this
            DispatchQueue.main.async {
                let walkingRunningDistance = sum.doubleValue(for: HKUnit.mile())
                self.lifetimeDistance = walkingRunningDistance
            }
            
        }
        
            self.healthStore.execute(query)
    }
    
    ///gets a user's lifetime distance in miles
    func readLifetimeDistance() {
        
        guard let walkingRunningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: .distantPast)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: walkingRunningType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            //all the healthkit stuff happens on a background thread. need to fix this.
            
            //changes must be published on the main thread. there has to be a better way to do this
            DispatchQueue.main.async {
                let walkingRunningDistance = sum.doubleValue(for: HKUnit.mile())
                self.walkingRunningDistance = walkingRunningDistance
            }
            
        }
        
            self.healthStore.execute(query)
        
    }
    
    //sets data for the stat item depending on what type it is
    func getData(forType: statType) -> String {
        switch forType {
        case .distance:
            return "\(String(format: "%.2f", walkingRunningDistance)) Miles"
            
        case .caloriesBurned:
            return "\(String(format: "%.2f", caloriesBurned)) KCal"
            
        case .stepCount:
            return "\(String(stepCount)) Steps"
        default:
            return "0.00"
        }
    }
    
    
}

