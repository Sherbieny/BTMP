//
//  Worker.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 15.02.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import Foundation
import UIKit

class Worker {
    // MARK: Properties

    public let REPEAT_EVERY: Double = 60 // repeat listening if sound detected in seconds
      public let LISTENING_FREQUENCY: Double = 0.1 // in seconds
      public let LISTENING_INTERVAL: Int = 20 // listening interval in seconds
      public let START_AFTER: Int = 10000 // start after in milliseconds (10000 = 10 sec)

    let recorder: Recorder = Recorder()
    var listeningFrequency: Scheduler?
    var repeatingFrequency: Scheduler?
    var timerWorkItem: DispatchWorkItem?

    // MARK: Main functions

    public func start() {
        listeningFrequency = Scheduler(timeInterval: LISTENING_FREQUENCY)
        repeatingFrequency = Scheduler(timeInterval: REPEAT_EVERY)
        keepScreenOpen()
        createWorker()
        startTimer()
    }

    public func pause() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        stopRecorder()
        stopTimer()
        listeningFrequency?.suspend()
        print("recording paused... rerunning soon")
    }

    public func end() {
        endRecording()
        stopTimer()
        listeningFrequency?.finish()
        repeatingFrequency?.finish()
        releaseScreen()
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

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(START_AFTER), execute: timerWorkItem!)
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
