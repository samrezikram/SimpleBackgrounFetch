//
//  ExchangeRateViewModel.swift
//  SimpleBackgroundFetch
//
//  Created by Samrez Ikram on 31/10/2021.
//

import Foundation
class ExchangeRateViewModel : NSObject {
    
    private var apiService : NetworkManager!
    private(set) var bitcoinExchangeRates : BitcoinExchangeRate! {
        didSet {
            self.bindBitcoinExchangeRatesViewModelToController()
        }
    }
    
    var bindBitcoinExchangeRatesViewModelToController : (() -> ()) = {}
    
    override init() {
        super.init()
        self.apiService =  NetworkManager()
        getBitcoinExchngeRateResults()
    }
    
    func getBitcoinExchngeRateResults() {
        NetworkManager.getBitoinExchangeRate { exchangeRates in
            self.bitcoinExchangeRates = exchangeRates
        }
    }
}
