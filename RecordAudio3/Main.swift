//
//  Main.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 26/03/2019.
//  Copyright © 2019 Sherboapps. All rights reserved.
//

import Foundation


class Main {
    // MARK: Properties

    let startEvery: Double
    let listenEvery: Double
    var worker: Scheduler?// listen every 0.5 seconds
    var manager: Timer! // start worker every n minutes
    let recorder: Recorder = Recorder()
    var timeLeft: Int = 30
    
    
    
    init(startEvery: Double, listenEvery: Double) {
        
        self.startEvery = startEvery
        self.listenEvery = listenEvery
        
//        startRecorder()
//        startTimer(startEvery: startEvery)
//        startWorker(listenEvery: listenEvery)

    }
    
    
    
    
    // MARK: Custom Functions
    
//    func startRecorder() {
//        if !recorder.isRecording {
//            recorder.startRecording()
//        }
//    }
//
//    func startTimer(startEvery: Double) {
//        timeLeft = 30
//        manager = Timer.scheduledTimer(timeInterval: startEvery, target: self, selector: #selector(startSession), userInfo: nil, repeats: false)
//        manager.fire()
//    }
//
//    func startWorker(listenEvery: Double){
//    worker = Scheduler(frequency: 0.5, period: 30, repeatEvery: 120)
//    }
//
//    func stopTimer() {
//        manager.invalidate()
//    }
//
//    @objc func startSession() {
//        print("starting session")
//
//
//
//        worker?.eventHandler = {
//            print("Time left = \(self.timeLeft)")
//            self.timeLeft -= 1
//
//            // if silence for the amount of time, user slept, exit
//            if self.timeLeft <= 0 {
//                self.recorder.stopRecording()
//                self.stopTimer()
//                self.worker?.finish()
//
//                return
//            }
//
//            // If sound detected - stop recording, suspend session and exit, start again soon
//            if self.recorder.audioLevel > self.recorder.DETECTION_LEVEL {
//                print("sound detected!")
//                self.recorder.stopRecording()
//                self.stopTimer()
//                self.worker?.suspend()
//
//                return
//            }
//
//        }
//        worker?.resume()
//    }
}
