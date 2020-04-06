//
//  WalkthroughViewController.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 26.03.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var headingLabel: UILabel! {
        didSet {
            headingLabel.numberOfLines = 0
        }
    }

    @IBOutlet var contentLabel: UILabel! {
        didSet {
            contentLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties

    var index = 0
    var heading = ""
    var content = NSAttributedString()

    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text = heading
        contentLabel.attributedText = content
    }

    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width: self.contentLabel.frame.width, height: self.contentLabel.frame.height + 300)
    }
}
