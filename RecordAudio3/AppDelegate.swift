//
//  AppDelegate.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 17/03/2019.
//  Copyright © 2019 Sherboapps. All rights reserved.
//

import AVFoundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
//    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
//    var backgroundTaskTimer: Timer! = Timer()

    // MARK: Properties

    var scheduler: Scheduler?
    var recorder: Recorder?

    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
                                       object: nil)
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        if type == .began {
            // Interruption began, take appropriate actions
            print("interruption began ....")
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
            print("interruption flagged should resume ....")
                } else {
                    // Interruption Ended - playback should NOT resume
                    print("interruption flagged should end - no playback ....")
                }
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set fetch interval
        UIApplication.shared.setMinimumBackgroundFetchInterval(60)

        scheduler = Scheduler(timeInterval: 0.5)

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("fetch started")
        // Check if the scheduler status is suspended, resumed or finished

//        switch listener.worker?.state {
//        case .suspended:
//            listener.startRecorder()
//            listener.startTimer(startEvery: 10)
//            completionHandler(.newData)
//        case .resumed:
//            return
//        case .finished:
//            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
//            completionHandler(.noData)
//        case .none:
//            print("worker is dead")
//        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Start the recorder
        //print("starting recorder first time")
        //recorder?.startRecording()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // scheduler.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
