//
//  SettingsViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 23.10.2021.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var storageTimeNumberLabel: UILabel!
    @IBOutlet weak var storageTimeTextLabel: UILabel!
    @IBOutlet weak var storageTimeSlider: UISlider!
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        apiKeyTextField.delegate = self
        prepareApiKey()
        prepareStorageTimeInterval()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - IBActions
    @IBAction func webButtonTapped() {
        if let url = URL(string: "http://aviationstack.com") {
            UIApplication.shared.open(url)
            }
    }
    
    @IBAction func storageTimeSliderValueUpdated(_ sender: UISlider) {
        let storageTimeInterval = sender.value.rounded()
        sender.value = storageTimeInterval
        DataManager.storageTimeInterval = Double(storageTimeInterval * 3600)
        setStorageTimeLabelText(storageTimeValue: Int(storageTimeInterval))
    }
    
    // MARK: - Private Methods
    private func prepareApiKey() {
        guard let key = KeychainManager.shared.readData(service: kSecAttributes.service.rawValue,
                                                        account: kSecAttributes.account.rawValue) else {
            apiKeyTextField.placeholder = "No API key. Enter your API key here."
            return
        }
        apiKeyTextField.text = key
    }
    
    private func updateApiKey(key: String) {
        if key.isEmpty {
            _ = KeychainManager.shared.deleteData(service: kSecAttributes.service.rawValue,
                                                           account: kSecAttributes.account.rawValue)
            prepareApiKey()
        } else {
            _ = KeychainManager.shared.saveData(data: key,
                                                         service: kSecAttributes.service.rawValue,
                                                         account: kSecAttributes.account.rawValue)
            
        }
    }
    
    private func prepareStorageTimeInterval() {
        let storageTimeInterval = Float(DataManager.storageTimeInterval / 3600)        
        storageTimeSlider.setValue(storageTimeInterval, animated: true)
        setStorageTimeLabelText(storageTimeValue: Int(storageTimeInterval))
    }
    
    private func setStorageTimeLabelText(storageTimeValue: Int) {
        switch storageTimeValue {
        case 1:
            storageTimeNumberLabel.text = "\(storageTimeValue)"
            storageTimeTextLabel.text = "hour"
        default:
            storageTimeNumberLabel.text = "\(storageTimeValue)"
            storageTimeTextLabel.text = "hours"
        }
    }
    
    // MARK: - Internal Methods
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    internal func textFieldDidEndEditing(_ textField: UITextField) {
        guard let apiKey = textField.text else { return }
        updateApiKey(key: apiKey)
    }
}
