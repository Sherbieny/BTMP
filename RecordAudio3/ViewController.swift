//
//  ViewController.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 17/03/2019.
//  Copyright Â© 2019 Sherboapps. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
    // MARK: Outlets

    @IBOutlet var startButton: StartToggleButton!

    // MARK: Properties

    let worker: Worker = Worker()
    var startButtonIsActive = false

    private var timer: Timer?
    var timeLeft: Int = 0

    let delegate = UIApplication.shared.delegate

    override func viewDidLoad() {
        super.viewDidLoad()
        initEvents()
        timeLeft = Int(worker.REPEAT_EVERY)
    }

    // MARK: Main functions

    @objc func start() {
        startButtonIsActive = true
        worker.start()
    }

    @objc func pause() {
        DispatchQueue.main.async {
            self.startButton.listeningButton()
        }
    }

    @objc func end() {
        startButtonIsActive = false
        worker.end()
        print("user pressed stop")
    }
    
    @objc func stop() {
            startButtonIsActive = false
            worker.stop()
        }
        

    func initEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDidEnterStart(_:)), name: .didEnterStart, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(onDidEnterWaiting(_:)), name: .didEnterWaiting, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(onDidEnterStop(_:)), name: .didEnterStop, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(onDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(onWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    // MARK: Event listeners

    @objc func onDidEnterStart(_ notification: Notification) {
        print("onDidEnterStart event!!!")
        // DispatchQueue.main.async {
        print("onDidEnterStart running!!!")

        if notification.userInfo == nil {
            print("onDidEnterStart initiating timer")
            DispatchQueue.main.async { self.startButton.stopButton() }
            resetTimer()
            initTimer()
        } else {
            print("onDidEnterStart resuming")
            DispatchQueue.main.async { self.startButton.listeningButton() }
            deinitTimer()
        }
        // }
    }

    @objc func onDidEnterWaiting(_ notification: Notification) {
        print("onDidEnterWaiting event!!!")

         DispatchQueue.main.async {
        print("onDidEnterWaiting running!!!")
        // self.startButton.waitingButton()
            self.resetTimer()
            self.initTimer()
         }
    }

    @objc func onDidEnterStop(_ notification: Notification) {
        print("onDidEnterStop event!!!")
        startButtonIsActive = false
        // DispatchQueue.main.async {
        print("onDidEnterStop running!!!")
        DispatchQueue.main.async { self.startButton.startButton() }
        deinitTimer()
        // }
    }

    @objc func onDidEnterBackground(_ notification: Notification) {
            stop()
    }

    @objc func onWillEnterForeground(_ notification: Notification) {
    }

    // MARK: Timer lifecycle

    private func initTimer() {
        print("VC: init timer")
        //timeLeft = Int(worker.REPEAT_EVERY)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    private func resetTimer() {
        print("VC: reset timer")
        timeLeft = Int(worker.REPEAT_EVERY)
    }

    @objc func updateTimer() {
        print("timeLeft = \(timeLeft)")
        startButton.addTimerText(text: timeFormatted(timeLeft)) // will show timer
        if timeLeft != 0 {
            timeLeft -= 1 // decrease counter timer
        } else {
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
            }
        }
    }

    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func getTimeDifference(startDate: Date) -> (Int) {
        print("getTimeDifference called")
        // let calendar = Calendar.current
        // let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
        let diffInSeconds = Date().timeIntervalSince(startDate)
        print("time diff = \(diffInSeconds) seconds")
        // return(components.hour!, components.minute!, components.second!)
        return Int(diffInSeconds)
    }

    private func deinitTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: Actions

    @IBAction func startDidTouch(_ sender: AnyObject) {
        if startButtonIsActive == false {
            print("start pressed")
            start()
        } else {
            print("stop pressed")
            stop()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

extension Notification.Name {
    static let didEnterWaiting = Notification.Name("didEnterWaiting")
    static let didEnterStop = Notification.Name("didEnterStop")
    static let didEnterStart = Notification.Name("didEnterStart")
}
