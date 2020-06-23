//
//  StringFormatter.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 26.03.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import Foundation
import UIKit

public class TextProvider {
    // MARK: - Properties

    let bullet = "•  "
    let pageHeadings = ["Thank you for choosing BTMP", "The way it works", "The Microphone", "The Music Library", "The Screen", "The Subscriptions"]

    // MARK: - Functions

    func getPageCount() -> Int {
        return pageHeadings.count
    }

    func getHeading(forPage: Int) -> String {
        return pageHeadings.indices.contains(forPage) ? pageHeadings[forPage] : ""
    }

    func getText(forPage: Int) -> NSAttributedString {
        var strings = [String]()
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.white,
        ]

        let paragraphStyle = NSMutableParagraphStyle()

        switch forPage {
        case 0:
            paragraphStyle.alignment = .justified

            strings.append("Please read the following information carefully before using the app. It includes the access permissions needed for the app to work and how the app is used.")
        case 1:
            strings.append("Simply put: it works as if someone is reading you a bedtime story, the app checks on you from time to time to see if you slept or not. It pauses what's playing and wait for you to tell it to resume if you are still awake.")
            strings.append("Note: the following can be viewed again from the settings page.")
            strings.append("Put your phone at the usual place you use when you go to bed.")
            strings.append("Play some media (music, audiobook, podcast, etc...) then switch back to this app and press start.")
            strings.append("Keep the app open and go to bed.")
            strings.append("In 30 seconds the media will stop (the time can be changed later from settings)")
            strings.append("Now make a sound (eg: a clap, a shout, a cough...)")
            strings.append("If the sound is loud enough the media will resume.")
            strings.append("If not, open the settings page, adjust the Listening Sensitivity setting and try again.")
            strings.append("Note that the lower the \"Listening Sensitivity\" the louder you need to be when making a sound.")

            for (index, line) in strings.enumerated() {
                if index > 1 {
                    strings[index] = bullet + line
                }
            }
        case 2:
            paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
            strings.append("In order for the app to work:")
            strings.append("it needs access to your microphone.")
            strings.append("the app does not save any recordings it makes, it just uses the microphone to detect sound.")
            strings.append("if the Grant Access button is visible below, please press it.")
            // strings = strings.map { bullet + $0 }
            for (index, line) in strings.enumerated() {
                if index != 0 {
                    strings[index] = bullet + line
                }
            }
        case 3:
            paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
            strings.append("In order for the app to work:")
            strings.append("it needs access to your music library")
            strings.append("you need to have at least one item present in your library")
            strings.append("otherwise we cannot guarantee if the app will be able to stop what you were listening to")
            strings.append("if the Grant Access button is visible below, please press it.")
            // strings = strings.compactMap { bullet + $0 }
            for (index, line) in strings.enumerated() {
                if index != 0 {
                    strings[index] = bullet + line
                }
            }
        case 4:
            paragraphStyle.alignment = .justified

            strings.append("You need to keep the app opened while it is working, locking your phone, pressing the home button or switching to another app will stop the application.")
            strings.append("This is to prevent apps from accessing the microphone while in the background or when the phone is locked for security reasons.")
            strings.append("As long as this app is opened, the phone will not automatically lock after some time.")
            strings.append("But don't worry, once you go to sleep and no sound is detected, the app will stop and the phone will lock automatically.")
        case 5:
            paragraphStyle.alignment = .justified

            strings.append("The app offers a non-renewing (31 days) subscription to be able to enjoy it fully.")
            strings.append("Try out the app without subscribing to be able to see how it works")
            strings.append("You can cancel the subscrition from your normal iTunes settings at anytime.")

        default:
            strings.append("")
        }
        attributes[.paragraphStyle] = paragraphStyle
        let string = strings.joined(separator: "\n\n")

        return NSAttributedString(string: string, attributes: attributes)
    }
}
