//
//  ViewController.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 17/03/2019.
//  Copyright © 2019 Sherboapps. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
    // MARK: Outlets

    @IBOutlet var startButton: StartToggleButton!

    // MARK: Properties

    let recorder: Recorder = Recorder()
    var schedulerFrequency: Scheduler?
    var schedulerRepeater: Scheduler?
    var flag: Bool = false
    // var timer: Timer!
    let SOUND_FLAG: Float = 50.0
    let REPEAT_EVERY: Double = 60 // repeat listening if sound detected in seconds
    let LISTENING_FREQUENCY: Double = 0.1 // in seconds
    let LISTENING_INTERVAL: Int = 20 // listening interval in seconds
    let START_AFTER: Int = 10000 // start after in milliseconds (10000 = 10 sec)
    
    
    var startButtonIsActive = false
    var timerWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        schedulerFrequency = Scheduler(timeInterval: LISTENING_FREQUENCY)
        schedulerRepeater = Scheduler(timeInterval: REPEAT_EVERY)
    }

    // MARK: Main functions

    @objc func start() {
        startButtonIsActive = true
        keepScreenOpen()
        createWorker()
        startTimer()
    }

    @objc func pause() {
        recorder.audioLevel = recorder.SILENCE_LEVEL
        stopRecorder()
        stopTimer()
        schedulerFrequency?.suspend()
        print("recording paused... rerunning soon")
    }

    @objc func end() {
        startButtonIsActive = false
        endRecording()
        stopTimer()
        schedulerFrequency?.finish()
        schedulerRepeater?.finish()
        DispatchQueue.main.async {
            self.startButton.deactivateButton()
        }
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

        schedulerRepeater?.eventHandler = {
            print("repeater event started")
            self.startRecorder()
            let startTime = DispatchTime.now()
            let endTime = startTime + DispatchTimeInterval.seconds(self.LISTENING_INTERVAL)
            
            self.schedulerFrequency?.eventHandler = {
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
            self.schedulerFrequency?.resume()
        }
        schedulerRepeater?.resume()
    }

    // MARK: Actions

    @IBAction func startDidTouch(_ sender: AnyObject) {
        if startButtonIsActive == false {
            start()
        } else {
            end()
        }
    }

//    @IBAction func stopDidTouch(_ sender: AnyObject) {
//        stopRecorder()
//        stopTimer()
//        self.schedulerFrequency?.finish()
//        self.schedulerRepeater?.finish()
//        print("recording finished...")
//        UIApplication.shared.isIdleTimerDisabled = false
//    }
}
