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

    public var isRunning: Bool = false
    let config: Config = Config()
    let recorder: Recorder = Recorder()
    var listeningFrequency: Scheduler?
    var repeatingFrequency: Scheduler?
    let permission: Permissions = Permissions()

    override init() {
        print("Worker: init")
        listeningFrequency = Scheduler()
        repeatingFrequency = Scheduler(withTime: true)
    }

    // MARK: Main functions

    public func start() {
        // Check for microphone and music library permissions before starting
        permission.requestMicrophoneAccess()
        permission.requestMusicLibraryAccess()

        recorder.audioLevel = recorder.SILENCE_LEVEL
        keepScreenOpen()
        startSession()
        isRunning = true
        NotificationCenter.default.post(name: .didEnterStart, object: self)
    }

    public func pause() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        stopRecorder()
        listeningFrequency?.suspend()
        NotificationCenter.default.post(name: .didEnterWaiting, object: self)
        print("recording paused... rerunning soon")
    }

    public func end() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        endRecording()
        listeningFrequency?.suspend()
        repeatingFrequency?.finish()
        releaseScreen()
        isRunning = false
        NotificationCenter.default.post(name: .didEnterStop, object: self)
    }

    public func stop() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        stopRecorder()
        listeningFrequency?.suspend()
        repeatingFrequency?.finish()
        releaseScreen()
        isRunning = false
        NotificationCenter.default.post(name: .didEnterStop, object: self)
    }

    public func reset() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        stopRecorder()
        listeningFrequency?.suspend()
        repeatingFrequency?.reset()
        NotificationCenter.default.post(name: .didEnterStop, object: self)
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
        // DispatchQueue.main.sync {
        recorder.stopMedia()
        // }
    }

    // MARK: Session functions

    @objc func startSession() {
        print("starting session")
        repeatingFrequency?.eventHandler = {
            print("repeater event started")
            print("listening duration = \(self.config.getListeningDuration())")
            self.startRecorder()
            let startTime = DispatchTime.now()
            let endTime = startTime + DispatchTimeInterval.seconds(self.config.getListeningDuration())

            NotificationCenter.default.post(name: .didEnterStart, object: self, userInfo: ["resuming": true])

            self.listeningFrequency?.eventHandler = {
                print("startTime = \(DispatchTime.now()) end time = \(endTime)")

                print("audio level  == \(self.recorder.audioLevel)")
                //let x = endTime.rawValue - DispatchTime.now().rawValue
                //print("time lefft = \(x)")
                // if silence for the amount of time, user slept, exit
                if DispatchTime.now() >= endTime {
                    print("silence went to sleep....")
                    self.end()
                    print("user went to sleeeeep")
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
