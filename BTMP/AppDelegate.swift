//
//  AppDelegate.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 17/03/2019.
//  Copyright © 2019 Sherboapps. All rights reserved.
//

import AVFoundation
import BackgroundTasks
import UIKit
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var callObserver: CXCallObserver!
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil)
        return true
    }   

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
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
extension AppDelegate: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
            NotificationCenter.default.post(name: .callDisconnected, object: self)
        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
            NotificationCenter.default.post(name: .incomingCall, object: self)
        }

        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
        }
    }
}
