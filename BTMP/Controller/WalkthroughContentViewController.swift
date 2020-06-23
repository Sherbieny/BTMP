//
//  WalkthroughViewController.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 26.03.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit

class WalkthroughContentViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var headingLabel: UILabel! {
        didSet {
            contentLabel.adjustsFontForContentSizeCategory = true
            contentLabel.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet var contentLabel: UILabel! {
        didSet {
            contentLabel.numberOfLines = 0
            contentLabel.adjustsFontForContentSizeCategory = true
            contentLabel.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet var scrollView: UIScrollView!

    // MARK: - Properties

    var index = 0
    var heading = ""
    var content = NSAttributedString()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if index == 1 {
            prepareVideoButton()
        }
        headingLabel.text = heading
        contentLabel.attributedText = content
    }

    func prepareVideoButton() {
        // prepare video button
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue]
        let buttonText = NSMutableAttributedString(string: "Watch video instead",
                                                   attributes: textAttributes)
        let button = UIButton()
        let width = buttonText.size().width
        let height = buttonText.size().height
        let buttonYPosition = headingLabel.frame.origin.y + headingLabel.frame.height + 20
        button.frame = CGRect(x: 0, y: buttonYPosition, width: width, height: height)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(.white, for: .normal)
        button.setAttributedTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)

        // get video controller
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc func playVideo() {
        if let url = Bundle.main.url(forResource: "Onboarding", withExtension: "mp4") {
            print("url found")
            let audioSession = AVAudioSession.sharedInstance()

            do {
                try audioSession.setCategory(.playback, mode: .moviePlayback)
                let videoPlayer = AVPlayer(url: url)
                let videoController = AVPlayerViewController()                
                videoController.player = videoPlayer
                present(videoController, animated: true) {
                    videoPlayer.play()
                }
            } catch {
                print("Setting category to AVAudioSessionCategoryPlayback failed.")
            }
        }
    }

//    override func viewDidLayoutSubviews() {
//        self.scrollView.contentSize = CGSize(width: self.contentLabel.frame.width, height: self.contentLabel.frame.height + 300)
//    }
}
