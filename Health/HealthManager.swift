//
//  HealthManager.swift
//  Health
//
//  Created by 张嘉夫 on 2017/3/3.
//  Copyright © 2017年 张嘉夫. All rights reserved.
//
//  This is where I'll add all the HealthKit related code this project needs; it will act as the gateway for other classes to interact with the HealthKit store.
//

import HealthKit

enum HealtManagerAuthorizationError:Error {
    case HealthDataUnavailable(userInfo: String)
}

class HealthManager {
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((_ success:Bool, _ error:Error?) -> Void)?){
        
        guard let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned), let basalEnergyBurnedType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned), let dietaryEnergyConsumedType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed) else {
            return
        }
        
        let healthKitTypesToRead: Set = [
            activeEnergyBurnedType,
            basalEnergyBurnedType,
            dietaryEnergyConsumedType
            ]
        
        if !HKHealthStore.isHealthDataAvailable() {
            let error = HealtManagerAuthorizationError.HealthDataUnavailable(userInfo: NSLocalizedString("HealthKit is not available in this Device", comment: "Healkit is not available in this Device"))
            completion?(false, error)
            return
        }
        
        healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            completion?(success, error)
        }
    }
    
    func readActiveEnergyBurned(completion: @escaping (_ result: Double) -> Void) {
        guard let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) else {
            fatalError("*** This method should never fail ***")
        }
        
        readTodayEnergyData(type: activeEnergyBurnedType, completion: completion)
    }
    
    func readBasalEnergyBurned(completion: @escaping (_ result: Double) -> Void) {
        guard let basalEnergyBurnedType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned) else {
            fatalError("*** This method should never fail ***")
        }
        
        readTodayEnergyData(type: basalEnergyBurnedType, completion: completion)
    }
    
    func readDietaryEnergyConsumed(completion: @escaping (_ result: Double) -> Void) {
        guard let dietaryEnergyConsumedType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed) else {
            fatalError("*** This method should never fail ***")
        }
        
        readTodayEnergyData(type: dietaryEnergyConsumedType, completion: completion)
    }

    
    private func readTodayEnergyData(type: HKQuantityType, completion: @escaping (_ result: Double) -> Void) {
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let components = calendar.dateComponents([.day, .month, .year], from: Date())

        guard let startDate = calendar.date(from: components) else {
            return
        }

        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
            
            completion(result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0)
            
        }
        
        healthKitStore.execute(query)
    }
}
