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
    @IBOutlet var backButton: UIButton!
    @IBOutlet var tutorialButton: UIButton!
    @IBOutlet var subscriptionButton: UIButton!
    @IBOutlet var frequencyInfoButton: UIButton!
    @IBOutlet var durationInfoButton: UIButton!
    @IBOutlet var senstivityInfoButton: UIButton!

    let config: Config = Config()
    var frequencyData: [String] = [String]()
    let durationData: [String] = ["10", "20", "30", "40", "50"]
    var didSettingsChange: Bool = false

    // MARK: - override view functions

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none

        initFrequencyArray()
        ListeningFrequency.delegate = self
        ListeningFrequency.dataSource = self
        ListeningDuration.delegate = self
        ListeningDuration.dataSource = self

        print("sensitivity = \(config.getSoundLevel())")

        // invert sound to show correct slider position
        let soundLevelForSlider: Float = 100 - config.getSoundLevel()

        ListeningFrequency.selectRow(config.getListeningFrequencyKey(), inComponent: 0, animated: true)
        ListeningDuration.selectRow(config.getListeningDurationKey(), inComponent: 0, animated: true)
        ListeningSenstivity.setValue(soundLevelForSlider, animated: true)

        ListeningSenstivity.addTarget(self, action: #selector(sliderTouchDownRepeat(_:)), for: .touchDownRepeat)
        ListeningSenstivity.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("closing view")
        if didSettingsChange {
            NotificationCenter.default.post(name: .didUserDefaultsChange, object: self)
        }
        //reset settings if they are invalid
        
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

    @IBAction func frequencyInfoButtonClicked(_ sender: UIButton) {
        alertInfo(with: "Listening Frequency", message: Messages.frequencyInfo)
    }

    @IBAction func durationInfoButtonClicked(_ sender: UIButton) {
        alertInfo(with: "Listening Duration", message: Messages.durationInfo)
    }

    @IBAction func senstivityInfoButtonClicked(_ sender: UIButton) {
        alertInfo(with: "Listening Senstivity", message: Messages.senstivityInfo)
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

    /**
     if chosen duration is larger than 20 seconds - check for chosen frequency, frequency must be larger else repeater logic breaks
     */
    func areSettingsValid(row: Int, type: UIPickerView) -> Bool {
        var validityCase = 0
        var isValid = true

        switch type {
        case ListeningDuration:
            let selectedFrequencyRow = ListeningFrequency.selectedRow(inComponent: 0)
            print("selected frequency row = \(selectedFrequencyRow)")            
            // If user selected duration of 30 seconds or more, make sure frequency is 1 minute or more
            if row > 1 {
                if selectedFrequencyRow == 0 {
                    validityCase = 1
                }
            }
        case ListeningFrequency:
            // if user selected frequency of 30 seconds, duration must be less that 30 seconds
            let selectedDurationRow = ListeningDuration.selectedRow(inComponent: 0)
            print("selected duration row = \(selectedDurationRow)")
            if row == 0 {
                if selectedDurationRow > 1 {
                    validityCase = 1
                }
            } else {
                // if user selected frequence of 1 minute or more - check if user is subscribed
                if StoreObserver.shared.isAuthorizedForUsage == false {
                    validityCase = 2
                }
            }
            
        default:
            break
        }

        switch validityCase {
        case 1:
            alertError(with: "Invalid selection", message: "The Listenting duration must be less than the frequency chosen above, please either increase the frequency or decrease the duration")
            isValid = false
        case 2:
            alertSubscription(with: "Not Subscribed", message: "Please purchase a subscription from settings page in order to increase the frequency, the subscription unlocks the frequency for 31 days")
            isValid = false
        default:
            isValid = true
        }

        return isValid
    }

    // MARK: - Display Alert

    /// Creates and displays an alert.
    fileprivate func alertSubscription(with title: String, message: String) {
        
        //set frequency back in all cases, user can select a new one after purchasing
        ListeningFrequency.selectRow(self.config.getMinimumListeningFrequencyKey(), inComponent: 0, animated: true)
        
        let alertStyle = UIDevice.current.userInterfaceIdiom == .pad ? UIAlertController.Style.alert : UIAlertController.Style.actionSheet
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        let manageAction = UIAlertAction(title: NSLocalizedString(Messages.goToSubscriptions, comment: Messages.emptyString),
                                         style: .default, handler: { _ in
                                             let storyBoard = UIStoryboard(name: "Subscriptions", bundle: nil)
                                             if let subscriptionsViewController = storyBoard.instantiateViewController(withIdentifier: "parent") as? SubscriptionViewController {
                                                 let navigationController = UINavigationController(rootViewController: subscriptionsViewController)
                                                 self.present(navigationController, animated: true)
                                             }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString(Messages.cancelButton, comment: Messages.emptyString),
                                         style: .default, handler: nil)
        alertController.addAction(manageAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    fileprivate func alertError(with title: String, message: String) {
        let alertStyle = UIDevice.current.userInterfaceIdiom == .pad ? UIAlertController.Style.alert : UIAlertController.Style.actionSheet
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        let okAction = UIAlertAction(title: NSLocalizedString(Messages.okButton, comment: Messages.emptyString),
                                     style: .default, handler: { _ in
                                         self.ListeningDuration.selectRow(self.config.defaultDurationKey, inComponent: 0, animated: true)
                                        self.config.setListeningDuration(value: self.config.defaultDuration, key: self.config.defaultDurationKey)
                                        self.config.setListeningFrequency(value: self.config.defaultFrequency, key: self.config.defaultFrequencyKey)
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    /// Creates and displays an alert.
    fileprivate func alertInfo(with title: String, message: String) {
        let alertStyle = UIDevice.current.userInterfaceIdiom == .pad ? UIAlertController.Style.alert : UIAlertController.Style.actionSheet

        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        let cancelAction = UIAlertAction(title: NSLocalizedString(Messages.okButton, comment: Messages.emptyString),
                                         style: .default, handler: nil)

        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("row = \(String(describing: cell.reuseIdentifier))")
        if cell.reuseIdentifier != nil {
            cell.contentView.layer.borderColor = UIColor.white.cgColor
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.cornerRadius = 10
        }
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
            if areSettingsValid(row: row, type: pickerView) {
                config.setListeningFrequency(value: convertToSeconds(minutes: frequencyData[row]), key: row)
            }
        } else {
            if let seconds = Int(durationData[row]) {
                print("user selected duration = \(seconds)")
                print("user selected duration key = \(row)")

                if areSettingsValid(row: row, type: pickerView) {
                    config.setListeningDuration(value: seconds, key: row)
                }
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

    @objc func sliderTouchDownRepeat(_ slider: UISlider) {
        ListeningSenstivity.cancelTracking(with: nil)

        // Perform your own value change operation
        ListeningSenstivity.value = config.defaultSoundLevel
        print("slider value 1 = \(ListeningSenstivity.value)")
        sliderDidChange(ListeningSenstivity)
    }

    @objc func sliderDidChange(_ slider: UISlider) {
        print("slider value 2 = \(100 - ListeningSenstivity.value)")
        config.setSoundLevel(value: 100 - ListeningSenstivity.value)
        didSettingsChange = true
    }
}
