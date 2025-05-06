//
//  TimeManager.swift
//  Rise Shine Swing
//
//  Created by Vivek-JAM-E-328 on 18/09/24.
//

import Foundation

final class TimeManager {

    
    var startTime:Date = Date()
    
    init() {
        startTime = Date()
    }
    
    func start() {
        startTime = Date()
    }
    
    func calculateTimeTaken() -> Double{
        let endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)  // Calculate time difference
        // Print the time taken for the API call
        return timeInterval
    }
}
