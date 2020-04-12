//
//  MediaPlayer.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 08.04.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import AVFoundation
import Foundation

class Silencer {
    // MARK: - Properties

    var audioPlayer: AVAudioPlayer?
    let silenceFileUrl = Bundle.main.path(forResource: "10-seconds-of-silence", ofType: "mp3")

    // MARK: - Functions

    func playSilence() {
        if silenceFileUrl != nil {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: silenceFileUrl!))
                if audioPlayer?.prepareToPlay() == true {
                    print("prepared")
                    audioPlayer?.play()
                    print("alllll g-oooood")
                }

                // audioPlayer?.stop()
                
            } catch let error {
                print("error opening audio player \(error)")
            }
        } else {
            print("silence file not found")
        }
    }
}
