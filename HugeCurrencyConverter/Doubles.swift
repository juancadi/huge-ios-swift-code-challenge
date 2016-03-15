//
//  Floats.swift
//  HugeCurrencyConverter
//
//  Created by JUAN ANDRÉS CÁRDENAS DIAZ on 14/03/16.
//  Copyright © 2016 JUAN ANDRÉS CÁRDENAS DIAZ. All rights reserved.
//

import Foundation

extension Double {
    
    func asLocaleCurrency(localId: String) -> String {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: localId)
        return formatter.stringFromNumber(round(self*1000)/1000)!
    }
    
    
}
