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
    
    @IBOutlet weak var ListeningFrequency: UIPickerView!
    @IBOutlet weak var ListeningDuration: UIPickerView!
    @IBOutlet weak var ListeningSenstivity: UISlider!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TutorialButton: UIButton!
    
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
    
    @IBAction func tutorialClicked(sender: UIButton){
        print("show tutorial")
        
        let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyBoard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            present(walkthroughViewController,animated: true){
                walkthroughViewController.startAtPage(pageIndex: 4)
            }
        }
    }
    
    
    // MARK: - Helper functions

    func initFrequencyArray() {
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
            print("user selected frequency = \(frequencyData[row])")
            config.setListeningFrequency(value: convertToSeconds(minutes: frequencyData[row]), key: row)
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
