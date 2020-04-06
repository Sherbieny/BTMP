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
    let minimumFrequency: Double = 60 // in seconds
    let defaultFrequency: Double = 60 // in seconds
    let defaultFrequencyKey: Int = 1 // 
    
    let minimumDuration: Int = 10 // in seconds
    let defaultDuration: Int = 20 // in seconds
    let defaultDurationKey: Int = 1 //
    
    let minimumSoundLevel: Float = 10.0
    let defaultSoundLevel: Float = 50.0
    let defaultSoundLevelKey: Int = 1

    // MARK: getters/setters functions

    // MARK: Frequency
    func getListeningFrequency() -> Double {
        return defaults.exists(key: keys.frequency.rawValue) ? defaults.double(forKey: keys.frequency.rawValue) : defaultFrequency
    }

    func getListeningFrequencyKey() -> Int {
        return defaults.exists(key: keys.frequencyKey.rawValue) ? defaults.integer(forKey: keys.frequencyKey.rawValue) : defaultFrequencyKey
    }

    func setListeningFrequency(value: Double, key: Int) {
        defaults.set((value > minimumFrequency) ? value : minimumFrequency, forKey: keys.frequency.rawValue)
        defaults.set(key, forKey: keys.frequencyKey.rawValue)
        //NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
    }

    
    // MARK: Duration
    
    func getListeningDuration() -> Int {
        return defaults.exists(key: keys.duration.rawValue) ? defaults.integer(forKey: keys.duration.rawValue) : defaultDuration
    }

    func getListeningDurationKey() -> Int {
        return defaults.exists(key: keys.durationKey.rawValue) ? defaults.integer(forKey: keys.durationKey.rawValue) : defaultDurationKey
    }

    func setListeningDuration(value: Int, key: Int) {
        defaults.set((value > minimumDuration) ? value : minimumDuration, forKey: keys.duration.rawValue)
        defaults.set(key, forKey: keys.durationKey.rawValue)
        //NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
    }

    
    // MARK: Sound Level
    
    func getSoundLevel() -> Float {
        print("get sound level")
        return defaults.exists(key: keys.soundLevel.rawValue) ? defaults.float(forKey: keys.soundLevel.rawValue) : defaultSoundLevel
    }
    
    func getSoundLevelKey() -> Int {
         return defaults.exists(key: keys.soundLevelKey.rawValue) ? defaults.integer(forKey: keys.soundLevelKey.rawValue) : defaultSoundLevelKey
    }

    func setSoundLevel(value: Float) {
        defaults.set((value > minimumSoundLevel) ? value : minimumSoundLevel, forKey: keys.soundLevel.rawValue)
        //NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
    }
    
    // MARK: Onboarding screen
    
    func didUserFinishOnboarding() -> Bool {
        return defaults.exists(key: keys.onboarding.rawValue) ? defaults.bool(forKey: keys.onboarding.rawValue) : false
    }
    
    func setUserFinisOnboarding() {
        defaults.set(true, forKey: keys.onboarding.rawValue)
    }
}
