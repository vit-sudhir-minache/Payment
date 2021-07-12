//
//  TimeoutTimer.swift
//  Common
//
//  Created by DEV27 on 06/08/19.
//  Copyright © 2020 myApps. All rights reserved.
//

import Foundation

public class TimeoutTimer{
    
    public enum NotificationState: String{
        case START
        case TICK
        case END
        case PAUSE
    }
    
    fileprivate static let TAG = "TimeoutTimer"

    
    public static let shared = TimeoutTimer()
    
    fileprivate var timer: Timer?
    fileprivate var isTimerRunning = false
    fileprivate var totalSeconds = 0.0
    fileprivate var remainingSeconds = 0.0
    fileprivate var startTime:Date?
    
    public func initializeTimer(withSeconds seconds:TimeInterval){
        startTime = Date()
        totalSeconds = seconds
        remainingSeconds = seconds
        startTimer()
    }
    
    public func pauseTimer(){
        timer?.invalidate()
        NotificationCenter.default.post(name: Notification.Name(NotificationState.PAUSE.rawValue), object: nil)
    }
    
    public func stopTimer(){
        isTimerRunning = false
        startTime = nil
        timer?.invalidate()
        timer = nil
    }
    
    public func resumeTimer(){
        guard let start = startTime else{ return }
        
        if Date().compare(start) != ComparisonResult.orderedDescending
            || Date().timeIntervalSince(start) > totalSeconds{
            endTimer()
        }else{
            remainingSeconds = totalSeconds - Date().timeIntervalSince(start)
            startTimer()
        }
    }
    
    private func startTimer(){
        if isTimerRunning {timer?.invalidate()}
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats:true)
        isTimerRunning = true
        NotificationCenter.default.post(name: Notification.Name(NotificationState.START.rawValue), object: nil)
    }
    
    @objc private func timerRunning(){
        remainingSeconds -= 1
        if remainingSeconds < 0 {
            endTimer()
        }
        NotificationCenter.default.post(name: Notification.Name(NotificationState.TICK.rawValue), object: remainingSeconds)
    }
    
    private func endTimer(){
        isTimerRunning = false
        startTime = nil
        timer?.invalidate()
        timer = nil
        NotificationCenter.default.post(name: Notification.Name(NotificationState.END.rawValue), object: nil)
    }
    
    
    
    
}
