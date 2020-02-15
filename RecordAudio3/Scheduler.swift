//
//  Scheduler.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 24/03/2019.
//  Copyright © 2019 Sherboapps. All rights reserved.
//

import Foundation

public class Scheduler {
    // MARK: Properties

    let listeningFrequency: TimeInterval
    let listeningPeriod: TimeInterval
    let listenEvery: TimeInterval

    var frequencyEventHandler: (() -> Void)?
    var periodEventHandler: (() -> Void)?
    var repeaterEventHandler: (() -> Void)?
//    var periodTimer: Timer?

    public enum State {
        case suspended
        case resumed
        case finished
    }

    public var state: State = .suspended

    private lazy var frequencyTimer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: self.listeningFrequency)
        t.setEventHandler(handler: { [weak self] in
            self?.frequencyEventHandler?()
        })
        return t
    }()

    
    //TODO: make this countdown timer - check http://www.popcornomnom.com/countdown-timer-in-swift-5-for-ios/
    //private lazy var periodTimer: Timer.
    private lazy var periodTimer = Timer.scheduledTimer(timeInterval: listeningPeriod, target: ViewController(), selector: #selector(ViewController.doRecord), userInfo: nil, repeats: false)
    
    
    private lazy var repeatTimer: DispatchSourceTimer = {
        print("repeatTimer start")
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: self.listenEvery)
        t.setEventHandler(handler: { [weak self] in
            self?.repeaterEventHandler?()
        })
        return t
    }()

    // MARK: initializer

    init(frequency: TimeInterval, period: TimeInterval, repeatEvery: TimeInterval) {
        print("initializing scheduler")
        listeningFrequency = frequency
        listeningPeriod = period
        listenEvery = repeatEvery
        
        frequencyTimer.activate()
        repeatTimer.activate()
        
    }

    // MARK: deintializer

    deinit {
        frequencyTimer.setEventHandler {}
        frequencyTimer.cancel()

        periodTimer.invalidate()

        repeatTimer.setEventHandler {}
        repeatTimer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        start()        
    }

    // MARK: Functions

    func start() {
        if state == .resumed {
            return
        }
        state = .resumed
        frequencyTimer.resume() // listening resumes
        periodTimer.fire() // count down starts
//        repeatTimer.resume()
        // stop the repeater
        if repeatTimer.isCancelled == false {
            repeatTimer.cancel()
        }
        
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        frequencyTimer.suspend() // listening stops
        periodTimer.invalidate() // count down reset
        repeatTimer.activate() // repeater start
    }

    func finish() {
        if state == .finished {
            return
        }
        state = .finished
        frequencyTimer.cancel()
        periodTimer.invalidate()
        repeatTimer.cancel()
    }
}
