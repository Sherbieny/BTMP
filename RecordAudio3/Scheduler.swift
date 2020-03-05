//
//  Scheduler.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 24/03/2019.
//  Copyright Â© 2019 Sherboapps. All rights reserved.
//

import Foundation

public class Scheduler {
    // MARK: Properties

    var timeInterval: TimeInterval
    var eventHandler: (() -> Void)?
    var firstTime: Bool = false

    public enum State {
        case suspended
        case resumed
        case finished
    }

    public var state: State = .suspended

    private lazy var timer: DispatchSourceTimer = {
        print("Scheduler \(timeInterval): init timer called")
        let deadline: DispatchTime = DispatchTime.now() + timeInterval
        let t = DispatchSource.makeTimerSource(flags: .strict, queue: nil)
        t.schedule(deadline: deadline, repeating: self.timeInterval, leeway: .seconds(0))
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    // MARK: initializer

    init(timeInterval: TimeInterval = 0.1) {
        print("Scheduler \(timeInterval): init called")
        self.timeInterval = timeInterval
        firstTime = true
    }

    // MARK: deintializer

    deinit {
        if !timer.isCancelled {
            print("Scheduler \(timeInterval): cancelling from deinit")
            timer.setEventHandler {}
            timer.cancel()
            /*
             If the timer is suspended, calling cancel without resuming
             triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
             */
            resume()
            eventHandler = nil
        }
    }

    // MARK: Functions

    private func reset() {
        print("Scheduler \(timeInterval): reset")
        let deadline: DispatchTime = DispatchTime.now() + timeInterval

        print("Scheduler \(timeInterval): deadline = \(deadline)")
        print("Scheduler \(timeInterval): timeInterval = \(timeInterval)")
        print("Scheduler \(timeInterval): state = \(state)")

        timer.schedule(deadline: deadline, repeating: timeInterval, leeway: .seconds(0))
        state = .suspended
    }

    func resume() {
        if state == .resumed && timeInterval > 0.1 {
            print("Scheduler \(timeInterval): return early from resumed")
            return
        }
        if state == .finished && timeInterval > 0.1 {
            print("Scheduler \(timeInterval): reseting...")
            reset()
        }
        print("Scheduler \(timeInterval): resuming...")
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            print("Scheduler \(timeInterval): return early from suspended")
            return
        }
        print("Scheduler \(timeInterval): suspending...")
        state = .suspended
        timer.suspend()
    }

    func finish() {
        if state == .finished {
            print("Scheduler \(timeInterval): return early from finished")
            return
        }
        print("Scheduler \(timeInterval): finishing...")
        state = .finished
        timer.suspend()
    }
}
