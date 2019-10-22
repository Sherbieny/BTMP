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
    var scheduler: Scheduler?
    var flag: Bool = false
    //var timer: Timer!
    let SOUND_FLAG: Float = 50.0
    // var otherAudioPlaying = AVAudioSession.sharedInstance().isOtherAudioPlaying
    var intervalManager: Timer!
    var timeLeft: Int = 30
    let timeInterval: TimeInterval = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //        while true {
        //            print(recorder.ringBuffer)
        //        }
        scheduler = Scheduler(timeInterval: 0.5)
    }

    // MARK: Timer functions

    @objc func startTimer(startEvery: Double) {
        print("startTimer")
        timeLeft = 30
        intervalManager = Timer.scheduledTimer(timeInterval: startEvery, target: self, selector: #selector(startSession), userInfo: nil, repeats: false)
        intervalManager.fire()
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

    // MARK: Session functions

    @objc func startSession() {
        print("starting session")

        scheduler?.eventHandler = {
            //print("time left is \(self.timeLeft)")
            self.timeLeft -= 1
            print("audio level  == \(self.recorder.audioLevel)")
            // if silence for the amount of time, user slept, exit
            if self.timeLeft <= 0 {
                self.stopRecorder()
                self.stopTimer()
                self.scheduler?.finish()
                print("user went to sleeeeep")
                return
            }
            if self.recorder.audioLevel > self.recorder.DETECTION_LEVEL {
                print("SOUND DETECTED!!")
                self.recorder.audioLevel = self.recorder.SILENCE_LEVEL
                self.stopRecorder()
                self.stopTimer()
                self.scheduler?.suspend()
                print("recording stopped...")
                
                return
            }else{
                print("silence");
            }
        }
        scheduler?.resume()
    }

    // MARK: Actions

    @IBAction func startDidTouch(_ sender: AnyObject) {
        print("start button pressed")
        startRecorder()
        startTimer(startEvery: 0.1)
    }

    @IBAction func stopDidTouch(_ sender: AnyObject) {
        stopRecorder()
        stopTimer()
        self.scheduler?.finish()
        print("recording finished...")
    }
}
