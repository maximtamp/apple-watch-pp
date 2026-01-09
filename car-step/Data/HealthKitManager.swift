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
        
        Task {
            
        }
    }
    
    init(preview : Bool){
        self.steps = 7421
    }
    
    func isAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func requestStepAuthorization() async -> Bool {
        let steps = HKQuantityType(.stepCount)
        let healthTypes: Set = [steps]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            
            return await withCheckedContinuation { continuation in
                let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
                let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { [weak self] _, result, error in
                    guard let self = self else {
                        continuation.resume(returning: false)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let quantity = result?.sumQuantity(), error == nil {
                            self.steps = Int(quantity.doubleValue(for: .count()))
                            self.fetchTodaySteps()
                            continuation.resume(returning: true)
                        } else {
                            continuation.resume(returning: false)
                        }
                    }
                }
                
                self.healthStore.execute(query)
            }
            
        } catch {
            print("Error bij HealthKit authorization: \(error.localizedDescription)")
            return false
        }
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

