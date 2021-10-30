//
//  SharedPref.swift
//  SimpleBackgroundFetch
//
//  Created by Samrez Ikram on 31/10/2021.
//

import Foundation
class SharedPrefs
{
    private let defaults = UserDefaults.standard
  
    private let keyMinimumDesiredRate = "minimumDesiredRate"
    private let keyMaximumDesiredRate = "maximumDesiredRate"
  
    var minimumDesiredRate: String {
        set {
            defaults.setValue(newValue, forKey: keyMinimumDesiredRate)
        }
        get {
            return defaults.string(forKey: keyMinimumDesiredRate) ?? ""
        }
    }
    
    var maximumDesiredRate: String {
        set {
            defaults.setValue(newValue, forKey: keyMaximumDesiredRate)
        }
        get {
            return defaults.string(forKey: keyMaximumDesiredRate) ?? ""
        }
    }
  
    class var shared: SharedPrefs {
        struct Static {
            static let instance = SharedPrefs()
        }
      
        return Static.instance
    }
}
