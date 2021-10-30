//
//  ViewController.swift
//  SimpleBackgroundFetch
//
//  Created by Samrez Ikram on 31/10/2021.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var currentBitcoinRate: UILabel!
    @IBOutlet weak var updatedTime: UILabel!
    
    @IBOutlet weak var minimumDesiredRate: UITextField!
    @IBOutlet weak var maximumDesiredRate: UITextField!
    
    var activityIndicator = UIActivityIndicatorView()
    
    private var exchangeRatesViewModel : ExchangeRateViewModel!
    
    let progressHUD = ProgressHUD(text: "Loading..")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.retrieveSavedTextFieldValues()
        
        // Adds Progress indicator and hide it until request starts
        self.view.addSubview(progressHUD);
        progressHUD.hide();
        
        self.minimumDesiredRate.delegate = self
        self.maximumDesiredRate.delegate = self
        
        registerForNotifications()

        // Load/Update exchange Rates on app start
        self.callToViewModelForUIUpdate();
    }

    func callToViewModelForUIUpdate(){
        progressHUD.show()
        
        self.exchangeRatesViewModel =  ExchangeRateViewModel()
        self.exchangeRatesViewModel.bindBitcoinExchangeRatesViewModelToController = {
            DispatchQueue.main.async {
                self.progressHUD.hide()
                self.renderExchangeRateAndTime(rate: self.exchangeRatesViewModel.bitcoinExchangeRates?.bpi.usd.rate, updateTime: self.exchangeRatesViewModel.bitcoinExchangeRates?.time.updatedISO)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: { [weak self] in
            self?.callToViewModelForUIUpdate()
        })
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == self.minimumDesiredRate) {
            self.minimumDesiredRate.text = textField.text
            SharedPrefs.shared.minimumDesiredRate = textField.text ?? ""
        } else if(textField == self.maximumDesiredRate){
            self.maximumDesiredRate.text = textField.text
            SharedPrefs.shared.maximumDesiredRate = textField.text ?? ""
        }
        return true
    }
    
    func retrieveSavedTextFieldValues() {
        self.minimumDesiredRate.text = !SharedPrefs.shared.minimumDesiredRate.isEmpty ? SharedPrefs.shared.minimumDesiredRate :  ""
        self.maximumDesiredRate.text = !SharedPrefs.shared.maximumDesiredRate.isEmpty ? SharedPrefs.shared.maximumDesiredRate :  ""
    }
    
    func renderExchangeRateAndTime(rate: String?, updateTime: String?){
        DispatchQueue.main.async {
            self.currentBitcoinRate.text = rate ?? "Unable to fetch data"
            self.updatedTime.text =  updateTime != nil ? "Updated At: " + self.updatedAWhileAgo(utcTime: updateTime!) : "";
        }
    }
    
    // Utility functions
    func updatedAWhileAgo(utcTime: String)-> String {
        // creates dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = dateFormatter.date(from: utcTime)

        // change to a readable time format and change to current time zone
        dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        dateFormatter.timeZone = NSTimeZone.local
        let timeStamp = dateFormatter.string(from: date!)
        return timeStamp;
    }
    
    func registerForNotifications() {
        print("notification recieved 1")
        NotificationCenter.default.addObserver(forName: .latestExchangeRatesFetched, object: nil, queue: nil) { (notification) in
            if let uInfo = notification.userInfo, let bitcoinExchangeRates = uInfo["ExchangeRates"] as? BitcoinExchangeRate {
                print("notification recieved 2")
                    self.renderExchangeRateAndTime(rate: bitcoinExchangeRates.bpi.usd.rate, updateTime: bitcoinExchangeRates.time.updatedISO)
                }
            }
    }
}


