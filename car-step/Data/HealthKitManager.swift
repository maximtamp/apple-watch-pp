//
//  HealthKitManager.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import Foundation
import Combine
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var steps: Int = 0
    @AppStorage("isAllowedReadingSteps") var isAllowedReadingSteps: Bool?
    
    private func getTodaysDate() -> Date {
        Calendar.current.startOfDay(for: .now)
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

                let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: nil) { _, _, error in

                    DispatchQueue.main.async {
                        if error != nil {
                            continuation.resume(returning: false)
                        } else {
                            continuation.resume(returning: true)
                        }
                    }
                }

                self.healthStore.execute(query)
            }

        } catch {
            print("❌ Authorization error:", error)
            return false
        }
    }


    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: getTodaysDate(), end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            
            let stepCount: Int
            
            if let error = error as? NSError {
                if error.domain == HKErrorDomain && error.code == HKError.errorNoData.rawValue {
                    stepCount = 0
                } else {
                    print("Error fetching today's step data: \(error.localizedDescription)")
                    stepCount = 0
                }
            } else if let quantity = result?.sumQuantity() {
                stepCount = Int(quantity.doubleValue(for: .count()))
            } else {
                stepCount = 0
            }
            
            DispatchQueue.main.async {
                self.steps = stepCount
            }
        }
        
        healthStore.execute(query)
    }
    
    func getTodaySteps() -> Int {
        fetchTodaySteps()
        return steps
    }
    
    func checkStepAuthorizationPermission() async {
        if await requestStepAuthorization() {
            isAllowedReadingSteps = true
        } else {
            isAllowedReadingSteps = false
        }
    }
}

