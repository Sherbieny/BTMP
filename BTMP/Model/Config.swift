//
//  Config.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 07.03.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import Foundation

extension UserDefaults {
    func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

public class Config {
    enum keys: String {
        case duration
        case durationKey
        case frequency
        case frequencyKey
        case soundLevel
        case soundLevelKey
        case onboarding
    }

    let defaults = UserDefaults.standard
    let minimumFrequency: Double = 30 // in seconds
    let defaultFrequency: Double = 30 // in seconds
    let defaultFrequencyKey: Int = 0 //
    let trialFrequency: Double = 300 // in seconds
    let trialFrequencyKey: Int = 5 //

    let minimumDuration: Int = 10 // in seconds
    let defaultDuration: Int = 20 // in seconds
    let defaultDurationKey: Int = 1 //

    let minimumSoundLevel: Float = 20.0
    let defaultSoundLevel: Float = 50.0

    // let storeManager

    // MARK: getters/setters functions

    // MARK: Frequency

    func getListeningFrequency() -> Double {
        // Check for subscription validity first
        if StoreObserver.shared.isAuthorizedForUsage {
            return defaults.exists(key: keys.frequency.rawValue) ? defaults.double(forKey: keys.frequency.rawValue) : trialFrequency
        } else {
            return defaultFrequency
        }
    }

    func getListeningFrequencyKey() -> Int {
//        return defaults.exists(key: keys.frequencyKey.rawValue) ? defaults.integer(forKey: keys.frequencyKey.rawValue) : defaultFrequencyKey
        // Check for subscription validity first
        if StoreObserver.shared.isAuthorizedForUsage {
            return defaults.exists(key: keys.frequencyKey.rawValue) ? defaults.integer(forKey: keys.frequencyKey.rawValue) : trialFrequencyKey
        } else {
            return defaultFrequencyKey
        }
    }
    
    func getMinimumListeningFrequencyKey() -> Int {
        defaults.set(defaultFrequency, forKey: keys.frequency.rawValue)
        defaults.set(defaultFrequencyKey, forKey: keys.frequencyKey.rawValue)
        return defaultFrequencyKey
    }

    func setListeningFrequency(value: Double, key: Int) {
        defaults.set((value > minimumFrequency) ? value : minimumFrequency, forKey: keys.frequency.rawValue)
        defaults.set(key, forKey: keys.frequencyKey.rawValue)
        // NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
    }

    // MARK: Duration

    func getListeningDuration() -> Int {
        //Check for valid frequency and duration first in case it is not saved properly
        let savedDuration = defaults.exists(key: keys.duration.rawValue) ? defaults.integer(forKey: keys.duration.rawValue) : defaultDuration
        let savedFrequency = Int(getListeningFrequency())
        if savedDuration > savedFrequency {
            //exchange it and return 20 instead
            setListeningDuration(value: defaultDuration, key: defaultDurationKey)
            return defaultDuration
        }
        return defaults.exists(key: keys.duration.rawValue) ? defaults.integer(forKey: keys.duration.rawValue) : defaultDuration
    }

    func getListeningDurationKey() -> Int {
        return defaults.exists(key: keys.durationKey.rawValue) ? defaults.integer(forKey: keys.durationKey.rawValue) : defaultDurationKey
    }

    func getDefaultListeningDurationKey() -> Int {
        defaults.set(defaultDuration, forKey: keys.durationKey.rawValue)
        return defaultDurationKey
    }

    func setListeningDuration(value: Int, key: Int) {
        defaults.set((value > minimumDuration) ? value : minimumDuration, forKey: keys.duration.rawValue)
        defaults.set(key, forKey: keys.durationKey.rawValue)
        // NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
    }

    // MARK: Sound Level

    func getSoundLevel() -> Float {
        print("get sound level")
        return defaults.exists(key: keys.soundLevel.rawValue) ? defaults.float(forKey: keys.soundLevel.rawValue) : defaultSoundLevel
    }

    func setSoundLevel(value: Float) {
        print("setting value = \(value)")
        defaults.set((value > minimumSoundLevel) ? value : minimumSoundLevel, forKey: keys.soundLevel.rawValue)
        // NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
    }

    // MARK: Onboarding screen

    func didUserFinishOnboarding() -> Bool {
        return defaults.exists(key: keys.onboarding.rawValue) ? defaults.bool(forKey: keys.onboarding.rawValue) : false
    }

    func setUserFinisOnboarding() {
        defaults.set(true, forKey: keys.onboarding.rawValue)
        //trigger is autherized again
        Vault.shared.isAutherizedForUse{isAuth in
            Vault.shared.isAutherized = isAuth
        }
    }
}
