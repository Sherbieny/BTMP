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
    let bullet = "•  "

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
            paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
            strings.append("In order for the app to work:")
            strings.append("it needs access to your music library.")
            strings.append("you need to have at least one item present in your library.")
            strings.append("if the Grant Access button is visible below, please press it.")
            // strings = strings.compactMap { bullet + $0 }
            for (index, line) in strings.enumerated() {
                if index != 0 {
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
            paragraphStyle.alignment = .justified

            strings.append("You need to keep the app opened while it is working, locking your phone, pressing the home button or switching to another app will stop the application.")
            strings.append("This is due to a limitation made by apple preventing apps from accessing the microphone while the phone is locked for security reasons.")
             strings.append("As long as this app is opened, the phone will not automatically lock after some time.")
            strings.append("But don't worry, once you go to sleep and no sound is detected, the app will stop and the phone will lock automatically.")
        case 4:
            //paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
            strings.append("Simply put: it works as if someone is reading you a bedtime story and every now and then they stop and check if you went to sleep, you need to make a sound in order for them to continue.")
            strings.append("Note: the following can be viewed again from the settings page.")
            strings.append("Put your phone at the usual place you use when you go to bed.")
            strings.append("play some media (music, audiobook, podcast, etc...) switch back to this app and press start.")
            strings.append("keep the app opened and go to bed.")
            strings.append("after 1 minute the media will stop (the time can be changed later from settings)")
            strings.append("now make a sound (a clap, a shout, a cough...)")
            strings.append("if the noise is loud enough the media will resume.")
            strings.append("if not, open the settings page and adjust the Listening Sensitivity setting and try again.")
            strings.append("note that the higher the \"Listening Sensitivity\" the louder you need to be when making a sound.")
            // strings = strings.map { bullet + $0 }
            for (index, line) in strings.enumerated() {
                if index > 1 {
                    strings[index] = bullet + line
                }
            }
        default:
            strings.append("")
        }
        attributes[.paragraphStyle] = paragraphStyle
        let string = strings.joined(separator: "\n\n")

        return NSAttributedString(string: string, attributes: attributes)
    }
}
