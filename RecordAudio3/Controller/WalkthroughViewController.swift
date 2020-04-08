//
//  WalkthroughViewController.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 26.03.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController, walkthroughPageViewControllerDelegate {
    // MARK: - Outlets

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = nextButton.layer.frame.height / 2
            nextButton.layer.masksToBounds = true
        }
    }

    @IBOutlet var actionButton: UIButton! {
        didSet {
            actionButton.isHidden = true
        }
    }

    // MARK: - Properties

    var walkthroughPageViewController: WalkthroughPageViewController?
    let config: Config = Config()
    let permissions: Permissions = Permissions()

    // MARK: - Actions

    @IBAction func nextButtonTapped(sender: UIButton) {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0 ... 2:
                walkthroughPageViewController?.forwardPage()
            case 3:
                dismiss(animated: true, completion: nil)
                config.setUserFinisOnboarding()
            default:
                break
            }

            updateUI()
        }
    }

    @IBAction func actionButtonTapped(sender: UIButton) {
        if let index = walkthroughPageViewController?.currentIndex {
            // Request Music Library access
            if index == 1 {
                permissions.requestMicrophoneAccess()
            }
        }
    }

    func updateUI() {
        print("update UI")
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            // Welcome page
            case 0:
                actionButton.isHidden = true
            // Microphone page
            case 1:
                print("page 2")
                nextButton.setTitle("Next", for: .normal)
                nextButton.isEnabled = true
                actionButton.setTitle("Grant Access", for: .normal)
                actionButton.isHidden = permissions.microphonePermissionStatus == .authorized
            // Screen page
            case 2:
                nextButton.setTitle("Next", for: .normal)
                nextButton.isEnabled = true
                actionButton.isHidden = true
            // the way it works page
            case 3:
                nextButton.setTitle("Get Started", for: .normal)
                actionButton.isHidden = true
            default:
                break
            }

            pageControl.currentPage = index
        }
    }

    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    func startAtPage(pageIndex: Int){
        walkthroughPageViewController?.goToPage(index: pageIndex)
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
}
