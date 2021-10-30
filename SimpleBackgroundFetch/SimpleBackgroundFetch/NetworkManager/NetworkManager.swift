//
//  NetworkManager.swift
//  SimpleBackgroundFetch
//
//  Created by Samrez Ikram on 31/10/2021.
//

import Foundation
import UIKit

class NetworkManager: NSObject {
    // preferring URLSession over NSURLRequest becuase of cache issues and we shell handle this soon.
    static let urlSession = URLSession(configuration: .default)
    
    static func getBitoinExchangeRate(completionHandler: @escaping (_ exchangeRates: BitcoinExchangeRate?) -> Void) {
        let coinDeskUrl = buildCoinDeskURL()
        print("coinDeskUrl %@", coinDeskUrl);
        let request = URLRequest(url: coinDeskUrl)

          let task = urlSession.dataTask(with: request) { (data, response, error) in
                  if let bitcoinExchangeData = data {
                      if let bitcoinExchangeRates = try? JSONDecoder().decode(BitcoinExchangeRate.self, from: bitcoinExchangeData) {
                          DispatchQueue.main.async {
                            completionHandler(bitcoinExchangeRates)
                          }
                      } else {
                          completionHandler(nil)
                          return
                      }
                     
                  }
                  if let error = error { // bring cached data against similar request In case of network failure or URL get changes.
                      print(error.localizedDescription)
                      if let cachedResponse = URLSession.shared.configuration.urlCache?.cachedResponse(for: request) {
                          let bitcoinExchangeData = cachedResponse.data
                          if let bitcoinExchangeRates = try? JSONDecoder().decode(BitcoinExchangeRate.self, from: bitcoinExchangeData) {
                              DispatchQueue.main.async {
                                completionHandler(bitcoinExchangeRates)
                                return
                              }
                          } else {
                              completionHandler(nil)
                              return
                          }
                      }
                  }
        }
        task.resume()
    }
  
    private static func buildCoinDeskURL() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.coindesk.com"
        urlComponents.path = "/v1/bpi/currentprice.json"
        return urlComponents.url!
  }
}
