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
    }

    let defaults = UserDefaults.standard
    let minimumFrequency: Double = 60 // in seconds
    let defaultFrequency: Double = 300 // in seconds
    let defaultFrequencyKey: Int = 4 // in seconds
    
    let minimumDuration: Int = 10 // in seconds
    let defaultDuration: Int = 20 // in seconds
    let defaultDurationKey: Int = 1 // in seconds
    let defaultSoundLevel: Float = 50.0
    let defaultSoundLevelKey: Float = 1

    // MARK: getters/setters functions

    func getListeningFrequency() -> Double {
        return defaults.exists(key: keys.frequency.rawValue) ? defaults.double(forKey: keys.frequency.rawValue) : defaultFrequency
    }

    func getListeningFrequencyKey() -> Int {
        return defaults.exists(key: keys.frequencyKey.rawValue) ? defaults.integer(forKey: keys.frequencyKey.rawValue) : defaultFrequencyKey
    }

    func setListeningFrequency(value: Double, key: Int) {
        defaults.set((value > minimumFrequency) ? value : minimumFrequency, forKey: keys.frequency.rawValue)
        defaults.set(key, forKey: keys.frequencyKey.rawValue)
        NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
    }

    func getListeningDuration() -> Int {
        return defaults.exists(key: keys.duration.rawValue) ? defaults.integer(forKey: keys.duration.rawValue) : defaultDuration
    }

    func getListeningDurationKey() -> Int {
        return defaults.exists(key: keys.durationKey.rawValue) ? defaults.integer(forKey: keys.durationKey.rawValue) : defaultDurationKey
    }

    func setListeningDuration(value: Int, key: Int) {
        defaults.set((value > minimumDuration) ? value : minimumDuration, forKey: keys.duration.rawValue)
        defaults.set(key, forKey: keys.durationKey.rawValue)
        NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
    }

    func getSoundLevel() -> Float {
        return defaults.exists(key: keys.soundLevel.rawValue) ? defaults.float(forKey: keys.soundLevel.rawValue) : defaultSoundLevel
    }

    func setSoundLevel(value: Float) {
        defaults.set((value > defaultSoundLevel) ? value : defaultSoundLevel, forKey: keys.soundLevel.rawValue)
    }
}
