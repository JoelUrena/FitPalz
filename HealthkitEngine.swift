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
    
    func readStepCountToday() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
          return
        }
        
        var dayBefore: Date {
            return Calendar.current.date(byAdding: .day, value: -1, to: .now)!
            }

        let now = Date()
        let startDate = Calendar.current.startOfDay(for: dayBefore)
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
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            self.stepCount = steps
            
        }
       
        healthStore.execute(query)
      }
    
    
}

