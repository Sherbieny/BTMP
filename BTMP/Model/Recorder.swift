//
//  Recorder.swift
//  RecordAudio3
//
//
//  Created by Ronald Nicholson on 10/21/16.  Updated 2017Feb07
//  Copyright Â© 2017 HotPaw Productions. All rights reserved.
//  Distribution: BSD 2-clause license
//

import AudioUnit
import AVFoundation
import Foundation
import MediaPlayer

final class Recorder: NSObject {
    // MARK: Properties

    var audioUnit: AudioUnit?
    var micPermission: Bool = false
    var isSessionActive: Bool = false
    var isAudioUnitActive: Bool = false
    var isAudioUnitInitialized: Bool = false
    var isRecording: Bool = false
    var sampleRate: Double = 44100.0
    var preferredIOBufferDuration: Double = 0.0058
    let musicPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
    let config: Config = Config()
    let silencer: Silencer = Silencer()

    public var DETECTION_LEVEL: Float = 50.0
    public let SILENCE_LEVEL: Float = 0.0

    let ringBufferSize: Int = 32768
    var ringBuffer: [Float] = [Float](repeating: 0, count: 32768)
    var ringIndex: Int = 0
    var audioLevel: Float = 0.0

    private var hwSampleRate: Double = 48000.0
    private var micPermissionDispatchToken: Int = 0
    private var isInterrupted: Bool = false

    var numberOfChannels: Int = 2
    private let outputBus: UInt32 = 0
    private let inputBus: UInt32 = 1

    var errorLogger: Int = 0

    // MARK: Functions

    func startRecording() {
        DETECTION_LEVEL = config.getSoundLevel()
        if isRecording { return }
        
        startAudioSession()
        if isSessionActive {
            startAudioUnit()
        }
    }

    func stopRecording() {
        stopAudioUnit()
        stopAudioSession()
        if !(isSessionActive && isAudioUnitActive && isAudioUnitInitialized) {
            print("Success: Stopped recording passed")
        } else {
            if isSessionActive { print("Error: stop recording failed at stopAudioSession") }
            if isAudioUnitActive { print("Error: stop recording failed at stopAudioUnit AudioOutputUnitStop") }
            if isAudioUnitInitialized { print("Error: stop recording failed at stopAudioUnit AudioUnitUninitialize") }
        }        
        isRecording = false
    }

    func stopMedia() {
        print("silencing")
        silencer.playSilence()        
    }

    func startAudioUnit() {
        var error: OSStatus = noErr

        if audioUnit == nil {
            setupAudioUnit()
        }

        if let audioUnit = self.audioUnit {
            error = AudioUnitInitialize(audioUnit)
            errorLogger = Int(error)

            if error != noErr {
                print("Error: Failed to initialize audiounit - error code == \(error)")
                return
            } else {
                isAudioUnitInitialized = true
            }
            error = AudioOutputUnitStart(audioUnit)

            errorLogger = Int(error)
            if error == noErr {
                isAudioUnitActive = true
                isRecording = true
            } else {
                print("Error: Failed to start audio unit - error code == \(error)")
            }
        } else {
            print("FAIL: audio unit not found!!! at startAudioUnit")
        }
    }

    func stopAudioUnit() {
        if let audioUnit = self.audioUnit {
            var error: OSStatus = noErr
            error = AudioOutputUnitStop(audioUnit)
            if error != noErr {
                print("Error: Failed to stop audiounit - error code == \(error)")
            } else {
                isAudioUnitActive = false
                print("audio unit stopped")
            }

            error = AudioUnitUninitialize(audioUnit)
            if error != noErr {
                print("Error: Failed to unitialize audiounit - error code == \(error)")
            } else {
                isAudioUnitInitialized = false
                print("audio unti unitialized")
            }
        } else {
            print("FAIL: no audio unit found!!! at stopAudioUnit")
        }
    }

    func startAudioSession() {
        if isSessionActive == false {
            // Set and activate audio session
            do {
                let audioSession = AVAudioSession.sharedInstance()

                let test = audioSession.secondaryAudioShouldBeSilencedHint

                print("other audio  = \(test)")

                if micPermission == false {
                    if micPermissionDispatchToken == 0 {
                        micPermissionDispatchToken = 1
                        audioSession.requestRecordPermission({ (granted: Bool) -> Void in
                            if granted {
                                self.micPermission = true
                                return
                                    // Check this flag and call UI from loop if needed
                            } else {
                                self.errorLogger += 1
                                // Dispatch in main/UI thread and alert
                                // informing that mic permission is not switched on
                            }
                        })
                    }
                }
                if micPermission == false { return }

                try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: [])
                // Choose 44100 or 4800 based on hardware rate
                // sampleRate = 44100.0

                hwSampleRate = audioSession.sampleRate // get native hw rate

                if hwSampleRate == 48000.0 {
                    sampleRate = 48000.0 // set session to hw rate
                    preferredIOBufferDuration = 0.0053
                }

                let desiredSampleRate = sampleRate

                try audioSession.setPreferredSampleRate(desiredSampleRate)
                try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)

                NotificationCenter.default.addObserver(
                    forName: AVAudioSession.interruptionNotification,
                    object: nil,
                    queue: nil,
                    using: myAudioSessionInterruptionHanlder
                )

                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                isSessionActive = true

            } catch let error as NSError {
                print("Error: Failed to set audio session active -- sending notificaition \(error)")
                NotificationCenter.default.post(name: .failedToStartSession, object: self)
            }
        } else {
            print("still active ya sh2eee2")
        }
    }

    func stopAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if audioSession.isOtherAudioPlaying {
                print("someone is playing....")
            }
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            isSessionActive = false
        } catch let error as NSError {
            print("Unable to deactivate audio session: \(error.localizedDescription)")
            print("retying.......")
        }
    }

    private func setupAudioUnit() {
        var componentDesc: AudioComponentDescription = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: UInt32(0),
            componentFlagsMask: UInt32(0)
        )

        var osError: OSStatus = noErr
        let component: AudioComponent! = AudioComponentFindNext(nil, &componentDesc)

        var tempAudioUnit: AudioUnit?
        osError = AudioComponentInstanceNew(component, &tempAudioUnit)
        self.audioUnit = tempAudioUnit

        guard let audioUnit = self.audioUnit else { return }

        // Enable I/O for input
        var one_ui32: UInt32 = 1

        osError = AudioUnitSetProperty(
            audioUnit,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Input,
            inputBus,
            &one_ui32,
            UInt32(MemoryLayout<UInt32>.size)
        )

        // Set format to 32-bit floats, linear PCM
        let noOfChannels = 2 // 2 channel sterio
        let memorySize = MemoryLayout<UInt32>.size
        var streamFormatDesc: AudioStreamBasicDescription = AudioStreamBasicDescription(
            mSampleRate: Double(sampleRate),
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagsNativeFloatPacked,
            mBytesPerPacket: UInt32(noOfChannels * memorySize),
            mFramesPerPacket: 1,
            mBytesPerFrame: UInt32(noOfChannels * memorySize),
            mChannelsPerFrame: UInt32(noOfChannels),
            mBitsPerChannel: UInt32(8 * memorySize),
            mReserved: UInt32(0)
        )

        osError = AudioUnitSetProperty(
            audioUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input,
            outputBus,
            &streamFormatDesc,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        )

        osError = AudioUnitSetProperty(
            audioUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Output,
            inputBus,
            &streamFormatDesc,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        )

        var inputCallbackStruct = AURenderCallbackStruct(
            inputProc: recordingCallBack,
            inputProcRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        osError = AudioUnitSetProperty(
            audioUnit,
            AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback),
            AudioUnitScope(kAudioUnitScope_Global),
            inputBus,
            &inputCallbackStruct,
            UInt32(MemoryLayout<AURenderCallbackStruct>.size)
        )

        // Ask CoreAudio to allocate buffers on render
        osError = AudioUnitSetProperty(
            audioUnit,
            AudioUnitPropertyID(kAudioUnitProperty_ShouldAllocateBuffer),
            AudioUnitScope(kAudioUnitScope_Output),
            inputBus,
            &one_ui32,
            UInt32(memorySize)
        )

        errorLogger = Int(osError)
    }

    let recordingCallBack: AURenderCallback = { (
        inRefCon,
        ioActionFlags,
        inTimeStamp,
        inBusNumber,
        frameCount,
        _
    ) -> OSStatus in

    let audioObject = unsafeBitCast(inRefCon, to: Recorder.self)
    var error: OSStatus = noErr

    // set mData to nil, AudioUnitRender() should be allocating buffers
    var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(
        mNumberChannels: UInt32(2),
        mDataByteSize: 2048,
        mData: nil
    ))

    if let audioUnit = audioObject.audioUnit {
        error = AudioUnitRender(
            audioUnit,
            ioActionFlags,
            inTimeStamp,
            inBusNumber,
            frameCount,
            &bufferList
        )
    }
    audioObject.processMicrophoneBuffer(inputDataList: &bufferList, frameCount: UInt32(frameCount))

    return 0
    }

    func processMicrophoneBuffer(inputDataList: UnsafeMutablePointer<AudioBufferList>, frameCount: UInt32) {
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let mBuffers: AudioBuffer = inputDataPtr[0]
        let count = Int(frameCount)

        let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)

        if let buffPointer = bufferPointer {
            let dataArray = buffPointer.assumingMemoryBound(to: Float.self)
            var sum: Float = 0.0
            var ringIdx = ringIndex
            let bufSize = ringBufferSize

            for i in 0 ..< (count / 2) {
                let x = Float(dataArray[i + i]) // copy left channel sample
                let y = Float(dataArray[i + i + 1]) // copy right channel sample
                ringBuffer[ringIdx] = x
                ringBuffer[ringIdx + 1] = y

                ringIdx += 2; if ringIdx >= bufSize { ringIdx = 0 }
                sum += x * x + y * y
            }
            ringIndex = ringIdx // ring index will always be less than size

            if sum > 0.0 && count > 0 {
                let tmp = 5.0 * (logf(sum / Float(count)) + 20.0)
                let r: Float = 0.2
                audioLevel = r * tmp + (1.0 - r) * audioLevel
            }
        }
    }

    func myAudioSessionInterruptionHanlder(notification: Notification) {
        let interruptDict = notification.userInfo
        if let interruptionType = interruptDict?[AVAudioSessionInterruptionTypeKey] {
            let interruptionVal = AVAudioSession.InterruptionType(rawValue: (interruptionType as AnyObject).uintValue)
            if interruptionVal == AVAudioSession.InterruptionType.began {
                if isRecording {
                    stopRecording()
                    isRecording = false
                    let audioSession = AVAudioSession.sharedInstance()
                    do {
                        try audioSession.setActive(false)
                        isSessionActive = false
                    } catch {
                        isInterrupted = true
                    }
                }
            } else if interruptionVal == AVAudioSession.InterruptionType.ended {
                if isInterrupted {
                    // Potentially restart here
                }
            }
        }
    }
}
