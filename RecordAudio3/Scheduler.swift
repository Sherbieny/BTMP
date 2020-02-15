//
//  Scheduler.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 24/03/2019.
//  Copyright Â© 2019 Sherboapps. All rights reserved.
//

import Foundation

public class Scheduler {
    
    
    //MARK: Properties
    
    let timeInterval: TimeInterval
    var eventHandler: (() -> Void)?
    
    public enum State {
        case suspended
        case resumed
        case finished
    }
    
    public var state: State = .suspended
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    //MARK: initializer
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
 
    //MARK: deintializer
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
    
    //MARK: Functions
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    func finish() {
        if state == .finished {
            return
        }
        state = .finished
        timer.suspend()
    }
}
