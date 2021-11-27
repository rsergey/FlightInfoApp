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
    @IBOutlet weak var storageTimeLabel: UILabel!
    
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
    
    // MARK: - Private Methods
    private func prepareApiKey() {
        
    }
    
    private func prepareStorageTimeInterval() {
        
    }
    
    // MARK: - Internal Methods
    internal func textFieldDidEndEditing(_ textField: UITextField) {
        guard let apiKey = textField.text else { return }
        print("Save to keychain " + apiKey)
    }
}
