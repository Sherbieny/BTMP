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
    private lazy var periodTimer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + .milliseconds(Int(self.listeningPeriod * 1000)), repeating: .never)
        t.setEventHandler(handler: { [weak self] in
            self?.periodEventHandler?()
        })
        return t
    }()

    private lazy var repeatTimer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: self.listenEvery)
        t.setEventHandler(handler: { [weak self] in
            self?.repeaterEventHandler?()
        })
        return t
    }()

    // MARK: initializer

    init(frequency: TimeInterval, period: TimeInterval, repeatEvery: TimeInterval) {
        listeningFrequency = frequency
        listeningPeriod = period
        listenEvery = repeatEvery
    }

    // MARK: deintializer

    deinit {
        frequencyTimer.setEventHandler {}
        frequencyTimer.cancel()

        periodTimer.setEventHandler {}
        periodTimer.cancel()

        repeatTimer.setEventHandler {}
        repeatTimer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()        
    }

    // MARK: Functions

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        frequencyTimer.resume() // listening resumes
        periodTimer.activate() // count down starts
        
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
        periodTimer.cancel() // count down reset
        repeatTimer.activate() // repeater start
    }

    func finish() {
        if state == .finished {
            return
        }
        state = .finished
        frequencyTimer.cancel()
        periodTimer.cancel()
        repeatTimer.cancel()
    }
}
