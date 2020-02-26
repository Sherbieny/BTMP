//
//  Worker.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 15.02.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import Foundation
import UIKit

class Worker: NSObject {
    // MARK: Properties

    public let REPEAT_EVERY: Double = 60 // in seconds - repeat listening if sound detected
    public let LISTENING_FREQUENCY: Double = 0.1 // in seconds - listening percision
    public let LISTENING_INTERVAL: Int = 20 // in seconds -  listening interval
    public let START_AFTER: Int = 10000 // in milliseconds -  start after (10000 = 10 sec)

    let recorder: Recorder = Recorder()
    var listeningFrequency: Scheduler?
    var repeatingFrequency: Scheduler?
    var timerWorkItem: DispatchWorkItem?

    override init() {
        print("Worker: init")
        listeningFrequency = Scheduler(timeInterval: LISTENING_FREQUENCY)
        repeatingFrequency = Scheduler(timeInterval: REPEAT_EVERY)
    }

    // MARK: Main functions

    public func start() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        keepScreenOpen()
        createWorker()
        startTimer()
        NotificationCenter.default.post(name: .didEnterStart, object: self)
    }

    public func pause() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        stopRecorder()
        stopTimer()
        listeningFrequency?.suspend()
        NotificationCenter.default.post(name: .didEnterWaiting, object: self)
        print("recording paused... rerunning soon")
    }

    public func end() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        endRecording()
        stopTimer()
        listeningFrequency?.finish()
        repeatingFrequency?.finish()
        releaseScreen()
        NotificationCenter.default.post(name: .didEnterStop, object: self)
        print("user went to sleeeeep")
    }

    // MARK: Screen functions

    func keepScreenOpen() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    func releaseScreen() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: Worker functions

    func createWorker() {
        timerWorkItem = DispatchWorkItem { [weak self] in
            self?.startSession()
        }
    }

    // MARK: Timer functions

    func startTimer() {
        print("startTimer")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(REPEAT_EVERY)), execute: timerWorkItem!)
    }

    func stopTimer() {
        timerWorkItem?.cancel()
    }

    // MARK: Recorder functions

    func startRecorder() {
        if !recorder.isRecording {
            recorder.startRecording()
        }
    }

    func stopRecorder() {
        if recorder.isRecording {
            recorder.stopRecording()
        }
    }

    func endRecording() {
        if recorder.isRecording {
            recorder.stopRecording()
        }
        recorder.stopMedia()
    }

    // MARK: Session functions

    @objc func startSession() {
        print("starting session")
        repeatingFrequency?.eventHandler = {
            print("repeater event started")

            self.startRecorder()
            let startTime = DispatchTime.now()
            let endTime = startTime + DispatchTimeInterval.seconds(self.LISTENING_INTERVAL)

            NotificationCenter.default.post(name: .didEnterStart, object: self, userInfo: ["resuming": true])

            self.listeningFrequency?.eventHandler = {
                print("startTime = \(DispatchTime.now()) end time = \(endTime)")

                print("audio level  == \(self.recorder.audioLevel)")
                // if silence for the amount of time, user slept, exit
                if DispatchTime.now() >= endTime {
                    print("silence......")
                    self.end()
                    return
                }
                if self.recorder.audioLevel > self.recorder.DETECTION_LEVEL {
                    print("SOUND DETECTED!!")
                    self.pause()
                    return
                } else {
                    print("silence")
                }
            }
            self.listeningFrequency?.resume()
        }
        repeatingFrequency?.resume()
    }
}
