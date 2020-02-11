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

    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!

    // MARK: Properties

    let recorder: Recorder = Recorder()
    var schedulerFrequency: Scheduler?
    var schedulerRepeater: Scheduler?
    var flag: Bool = false
    //var timer: Timer!
    let SOUND_FLAG: Float = 50.0
    let REPEAT_EVERY: Double = 60 // in seconds
    let LISTENING_FREQUENCY: Double = 0.5 // in seconds
    let LISTENING_INTERVAL: Double = 20 // listening interval
    let START_AFTER: Double = 60000 // start after in milliseconds
    
    var intervalManager: Timer!
    var timeLeft: Double = 0 // listening loop counter

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        schedulerFrequency = Scheduler(timeInterval: LISTENING_FREQUENCY)
        schedulerRepeater = Scheduler(timeInterval: REPEAT_EVERY)
     
    }

    // MARK: Timer functions

    @objc func startTimer(startAfter: Double) {
        print("startTimer")
        timeLeft = LISTENING_INTERVAL
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(60000)) {
            self.intervalManager = Timer.scheduledTimer(timeInterval: startAfter, target: self, selector: #selector(self.startSession), userInfo: nil, repeats: false)
            self.intervalManager.fire()
        }
        
    }

    @objc func stopTimer() {
        intervalManager.invalidate()
        //timer.invalidate()
    }

    // MARK: Recorder functions

    @objc func startRecorder() {
        if !recorder.isRecording {
            recorder.startRecording()
        }
    }

    @objc func stopRecorder() {
        if recorder.isRecording {
            recorder.stopRecording()
        }
    }
    
    @objc func endRecording(){
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
            
            self.schedulerFrequency?.eventHandler = {
                //print("time left is \(self.timeLeft)")
                self.timeLeft -= 1
                print("audio level  == \(self.recorder.audioLevel)")
                // if silence for the amount of time, user slept, exit
                if self.timeLeft <= 0 {
                    self.endRecording()
                    self.stopTimer()
                    self.schedulerFrequency?.finish()
                    self.schedulerRepeater?.finish()
                    print("user went to sleeeeep")
                    return
                }
                if self.recorder.audioLevel > self.recorder.DETECTION_LEVEL {
                    print("SOUND DETECTED!!")
                    self.recorder.audioLevel = self.recorder.SILENCE_LEVEL
                    self.timeLeft = self.LISTENING_INTERVAL
                    self.stopRecorder()
                    self.stopTimer()
                    self.schedulerFrequency?.suspend()
                    print("recording stopped...")
                    return
                }else{
                    print("silence");
                }
            }
            self.schedulerFrequency?.resume()
        }
        schedulerRepeater?.resume()

        
    }

    // MARK: Actions

    @IBAction func startDidTouch(_ sender: AnyObject) {
        print("start button pressed")
        UIApplication.shared.isIdleTimerDisabled = true
        startTimer(startAfter: 0.1)
    }

    @IBAction func stopDidTouch(_ sender: AnyObject) {
        stopRecorder()
        stopTimer()
        self.schedulerFrequency?.finish()
        self.schedulerRepeater?.finish()
        print("recording finished...")
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
