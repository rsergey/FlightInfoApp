//
//  SelectionViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 07.08.2021.
//

import UIKit

class SelectionViewController: UIViewController, UITextFieldDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var iataTextField: UITextField!
    
    // MARK: - Private Properties
    private var airportIata = ""

    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        iataTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tabBarController = segue.destination as? UITabBarController else { return }
        tabBarController.navigationItem.title = "Airport • " + airportIata
        guard let viewControllers = tabBarController.viewControllers else { return }
        for viewController in viewControllers {
            if let arrivalVC = viewController as? ArrivalTableViewController {
                arrivalVC.airportIata = airportIata
            }
            if let departureVC = viewController as? DepartureTableViewController {
                departureVC.airportIata = airportIata
            }
        }
    }
    
    // MARK: - Pablic Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (iataTextField.text?.count ?? 0) > 2 {
            airportIata = iataTextField.text ?? ""
            performSegue(withIdentifier: "showFlightsSegue", sender: nil)
        } else {
            showAlert()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let set = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwzyz").inverted
        let maxLength = 3
        let currentString = (textField.text ?? "") as NSString
        let newString : NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return (string.rangeOfCharacter(from: set) == nil) && (newString.length <= maxLength)
    }
    
    // MARK: - Private Methods
    private func showAlert() {
        let alert = UIAlertController(title: "Wrong IATA code!",
                                      message: "IATA aiport code contains three letters.",
                                      preferredStyle: .alert)
        let okButtonAction = UIAlertAction(title: "Ok", style: .default) { _ in
            self.iataTextField.becomeFirstResponder()
        }
        alert.addAction(okButtonAction)
        present(alert, animated: true)
    }

}
