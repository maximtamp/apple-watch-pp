//
//  HealthKitManager.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import Foundation
import Combine
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthKitManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var steps: Int = 0
        
    init() {
        let steps = HKQuantityType(.stepCount)
        
        let healthTypes: Set = [steps]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
            } catch {
                print("Error fetching health data: \(error.localizedDescription)")
            }
        }
    }
    
    init(preview : Bool){
        self.steps = 7421
    }
    
    func isAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays step data")
                return
            }
            
            let stepCount = Int(quantity.doubleValue(for: .count()))
            
            DispatchQueue.main.async {
                self.steps = stepCount
            }
        }
        
        healthStore.execute(query)
    }
    
}

