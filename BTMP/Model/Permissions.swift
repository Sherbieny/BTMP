//
//  Permissions.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 31.03.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import AVFoundation
import Foundation
import MediaPlayer

class Permissions {
    // MARK: - Properties

    let microphonePermissionStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    let musicLibraryPermissionStatus = MPMediaLibrary.authorizationStatus()

    // MARK: - Functions

    func requestMicrophoneAccess() {
        if microphonePermissionStatus != .authorized {
            AVCaptureDevice.requestAccess(for: .audio) { _ in }
        }
    }

    func requestMusicLibraryAccess() {
        if musicLibraryPermissionStatus != .authorized {
            MPMediaLibrary.requestAuthorization { _ in }
        }
    }
}
