//
//  MediaPlayer.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 08.04.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import AVFoundation
import Foundation
import MediaPlayer

class Silencer {
    // MARK: - Properties

    var audioPlayer: AVAudioPlayer?
    let silenceFileUrl = Bundle.main.path(forResource: "10-seconds-of-silence", ofType: "mp3")

    // MARK: - Functions

    func playSilence() {
        
        let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer
        let mediaItems = MPMediaQuery.songs().items

        if mediaItems != nil {
            let mediaCollection = MPMediaItemCollection(items: mediaItems!)

            systemMusicPlayer.setQueue(with: mediaCollection)
            systemMusicPlayer.prepareToPlay()
            print("playing")

            for _ in 1 ... 15 {
                systemMusicPlayer.play()
                systemMusicPlayer.stop()
            }

            systemMusicPlayer.stop()

        } else {
            print("failed to get items from library - falling back to audio player")
            if silenceFileUrl != nil {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: silenceFileUrl!))

                    if audioPlayer != nil {
                        audioPlayer!.numberOfLoops = 100
                        if audioPlayer!.prepareToPlay() == true {
                            audioPlayer!.play()
                            if audioPlayer!.isPlaying {
                                print("it is playing")
                            } else {
                                print("it not playing")
                            }
                        }
                    }else{
                        print("Error: audio player is nil")
                    }

                } catch let error {
                    print("error opening audio player \(error)")
                }
            } else {
                print("silence file not found")
            }
        }
    }
}
