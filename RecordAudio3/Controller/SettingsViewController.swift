//
//  SettingsTableViewController.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 05.03.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var ListeningFrequency: UIPickerView!
    @IBOutlet var ListeningDuration: UIPickerView!

    let config: Config = Config()
    var frequencyData: [String] = [String]()
    let durationData: [String] = ["10", "20", "30", "40", "50"]

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
        
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

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
            print("a7a")
            return 300
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
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

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case ListeningFrequency:
            return frequencyData[row]
        default:
            return durationData[row]
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
    }
}
