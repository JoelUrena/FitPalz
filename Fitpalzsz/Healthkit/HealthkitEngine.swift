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
    @Published var lifetimeCaloriesBurned: Double = 0.0
    @Published var walkingRunningDistance: Double = 0.0
    @Published var lifetimeDistance: Double = 0.0
    
    @Published var timeinDaylightToday: Int = 0
    @Published var timeinDaylightLifetime: Int = 0
    
    @Published var sleepTimePreviousNight: Double = 0
    
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
    
    func readlifeTimeCaloriesBurned() {
        guard let caloriesBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
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
                self.lifetimeCaloriesBurned = caloriesBurned
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
                self.walkingRunningDistance = walkingRunningDistance
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
                self.lifetimeDistance = walkingRunningDistance
            }
            
        }
        
        self.healthStore.execute(query)
        
    }
    
    func readTimeInDaylightToday() {
        guard let dayLightType = HKQuantityType.quantityType(forIdentifier: .timeInDaylight) else {
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: dayLightType, quantitySamplePredicate: predicate, options: .cumulativeSum) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to read time in daylight: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            
            // HealthKit queries run on a background thread; update UI on the main thread
            DispatchQueue.main.async {
                let timeInDaylight = Int(sum.doubleValue(for: HKUnit.minute()))
                self.timeinDaylightToday = timeInDaylight
            }
        }
        
        self.healthStore.execute(query)
    }
    
    
    func readLifetimeInDaylight() {
        guard let dayLightType = HKQuantityType.quantityType(forIdentifier: .timeInDaylight) else {
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
            options: []
        )
        
        let query = HKStatisticsQuery(
            quantityType: dayLightType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            
            DispatchQueue.main.async {
                let timeInDaylight = Int(sum.doubleValue(for: HKUnit.count()))
                self.timeinDaylightLifetime = timeInDaylight
            }
            
            
        }
        
        self.healthStore.execute(query)
    }
    
    func readSleepDataPreviousNight() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let now = Date()
        
        let startOfPreviousNight = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now.addingTimeInterval(-86400))!
        let endOfPreviousNight = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfPreviousNight,
            end: endOfPreviousNight,
            options: []
        )
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, samples, error) in
            guard let allSamples = samples as? [HKCategorySample] else {
                print("No sleep samples or failed to cast")
                return
            }
            
            // get all samples
            let samples = allSamples
            
            // Filter samples within the night window
            let filteredSamples = samples.filter {
                $0.startDate >= startOfPreviousNight && $0.endDate <= endOfPreviousNight
            }
            
            // Merge overlapping samples to avoid double-counting
            let sleepIntervals = filteredSamples.filter {
                $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue
            }.map {
                ($0.startDate, $0.endDate)
            }.sorted(by: { $0.0 < $1.0 })
            
            var mergedIntervals: [(Date, Date)] = []
            for interval in sleepIntervals {
                if let last = mergedIntervals.last, last.1 >= interval.0 {
                    // Merge overlapping
                    mergedIntervals[mergedIntervals.count - 1].1 = max(last.1, interval.1)
                } else {
                    mergedIntervals.append(interval)
                }
            }
            
            //  Sum non-overlapping durations
            let totalSleepSeconds = mergedIntervals.reduce(0.0) { acc, interval in
                acc + interval.1.timeIntervalSince(interval.0)
            }
            
            DispatchQueue.main.async {
                self.sleepTimePreviousNight = totalSleepSeconds
                print("Sleep time: \(self.sleepTimePreviousNight) seconds")
            }
        }
        
        healthStore.execute(query)
    }
    
    func readAllData() {
        
        readLifetimeSteps()
        readLifetimeDistance()
        readStepCountToday()
        readLifetimeInDaylight()
        readCaloiresBurnedToday()
        readlifeTimeCaloriesBurned()
        readTimeInDaylightToday()
        readSleepDataPreviousNight()
        readWalkingandRunningDistanceToday()
        
    }
    
    
    //one of the other important ones is the sleep metric
    
    //sets data for the stat item depending on what type it is
    func getData(forType: statType) -> String {
        switch forType {
        case .distance:
            return "\(String(format: "%.2f", walkingRunningDistance)) Miles"
            
        case .caloriesBurned:
            return "\(String(format: "%.2f", caloriesBurned)) KCal"
            
        case .stepCount:
            return "\(String(stepCount)) Steps"
            
        case .sleep:
            return "\(String(sleepTimePreviousNight/3600)) Hours of sleep last night"
        default:
            return "0.00"
        }
    }
    
    
}

