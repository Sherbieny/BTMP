//
//  SettingsTableViewController.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 05.03.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Properties

    @IBOutlet var ListeningFrequency: UIPickerView!
    @IBOutlet var ListeningDuration: UIPickerView!
    @IBOutlet var ListeningSenstivity: UISlider!
    @IBOutlet var backButton: UIButton! {
        didSet{
            backButton.titleLabel?.adjustsFontForContentSizeCategory = true
            backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet var tutorialButton: UIButton! {
        didSet{
            tutorialButton.titleLabel?.adjustsFontForContentSizeCategory = true
            tutorialButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet var subscriptionButton: UIButton! {
        didSet{
            subscriptionButton.titleLabel?.adjustsFontForContentSizeCategory = true
            subscriptionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }

    let config: Config = Config()
    var frequencyData: [String] = [String]()
    let durationData: [String] = ["10", "20", "30", "40", "50"]
    var didSettingsChange: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.tableView.rowHeight = 50
        initFrequencyArray()
        ListeningFrequency.delegate = self
        ListeningFrequency.dataSource = self
        ListeningDuration.delegate = self
        ListeningDuration.dataSource = self

        print("setting duration = \(config.getListeningDurationKey())")

        ListeningFrequency.selectRow(config.getListeningFrequencyKey(), inComponent: 0, animated: true)
        ListeningDuration.selectRow(config.getListeningDurationKey(), inComponent: 0, animated: true)
        ListeningSenstivity.setValue(config.getSoundLevel(), animated: true)

        ListeningSenstivity.addTarget(self, action: #selector(sliderTouchDownRepeat(_:)), for: .touchDownRepeat)
        ListeningSenstivity.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
    }

    // MARK: - Actions

    @IBAction func backClicked(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tutorialClicked(sender: UIButton) {
        print("show tutorial")

        let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyBoard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            present(walkthroughViewController, animated: true) {
                walkthroughViewController.startAtPage(pageIndex: 1)
            }
        }
    }

    @IBAction func SubscriptionsClicked(sender: UIButton) {
        print("show tutorial")

        let storyBoard = UIStoryboard(name: "Subscriptions", bundle: nil)
        if let subscriptionsViewController = storyBoard.instantiateViewController(withIdentifier: "parent") as? SubscriptionViewController {
            let navigationController = UINavigationController(rootViewController: subscriptionsViewController)
            present(navigationController, animated: true)
        }
    }

    // MARK: - Helper functions

    func initFrequencyArray() {
        frequencyData.append(String("0.5"))
        var i = 1
        while i < 31 {
            frequencyData.append(String(i))
            i += 1
        }
    }

    func convertToSeconds(minutes: String) -> Double {
        if let value = Double(minutes) {
            return value * 60.0
        } else {
            return 300.0
        }
    }

    // MARK: - Display Alert

    /// Creates and displays an alert.
    fileprivate func alert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let manageAction = UIAlertAction(title: NSLocalizedString(Messages.goToSubscriptions, comment: Messages.emptyString),
                                         style: .default, handler: { _ in
                                             let storyBoard = UIStoryboard(name: "Subscriptions", bundle: nil)
                                             if let subscriptionsViewController = storyBoard.instantiateViewController(withIdentifier: "parent") as? SubscriptionViewController {
                                                 let navigationController = UINavigationController(rootViewController: subscriptionsViewController)
                                                 self.present(navigationController, animated: true)
                                             }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString(Messages.cancelButton, comment: Messages.emptyString),
                                         style: .default, handler: {_ in
                                            self.ListeningFrequency.selectRow(self.config.getListeningFrequencyKey(), inComponent: 0, animated: true)
        })
        alertController.addAction(manageAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("closing view")
        if didSettingsChange {
            NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    // MARK: - PickerView functions

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case ListeningFrequency:
            return frequencyData.count
        default:
            return durationData.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("didSelectRow called")
        
        
        
        if pickerView == ListeningFrequency {
            if row == 0 {
                config.setListeningFrequency(value: convertToSeconds(minutes: frequencyData[row]), key: row)
            }else{
                if StoreObserver.shared.isAuthorizedForUsage {
                    print("user selected frequency = \(frequencyData[row])")
                    config.setListeningFrequency(value: convertToSeconds(minutes: frequencyData[row]), key: row)
                } else {
                    alert(with: "Not Subscribed", message: "Please purchase or restore a subscription from settings page in order to increase the frequency, first month is for free as a trial period")
                }
            }            
        } else {
            if let seconds = Int(durationData[row]) {
                print("user selected duration = \(seconds)")
                print("user selected duration key = \(row)")
                config.setListeningDuration(value: seconds, key: row)
            } else {
                print("a7eteen")
            }
        }
        didSettingsChange = true
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == ListeningFrequency {
            return NSAttributedString(string: frequencyData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        } else {
            return NSAttributedString(string: durationData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }

    // MARK: - slider functions

//    @IBAction func sliderValueChanged(_ sender: Any) {
//        print("slider value = \(ListeningSenstivity.value)")
//    }

    @objc func sliderTouchDownRepeat(_ slider: UISlider) {
        ListeningSenstivity.cancelTracking(with: nil)

        // Perform your own value change operation
        ListeningSenstivity.value = config.defaultSoundLevel
        print("slider value 1 = \(ListeningSenstivity.value)")
        sliderDidChange(ListeningSenstivity)
    }

    @objc func sliderDidChange(_ slider: UISlider) {
        print("slider value 2 = \(ListeningSenstivity.value)")
        config.setSoundLevel(value: ListeningSenstivity.value)
        didSettingsChange = true
    }
}
