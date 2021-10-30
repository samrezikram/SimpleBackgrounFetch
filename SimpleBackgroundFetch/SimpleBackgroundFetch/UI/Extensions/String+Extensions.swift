//
//  String+Extensions.swift
//  SimpleBackgroundFetch
//
//  Created by Samrez Ikram on 31/10/2021.
//

import Foundation
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
