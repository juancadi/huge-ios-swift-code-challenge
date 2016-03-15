//
//  Currency.swift
//  HugeCurrencyConverter
//
//  Created by JUAN ANDRÉS CÁRDENAS DIAZ on 14/03/16.
//  Copyright © 2016 JUAN ANDRÉS CÁRDENAS DIAZ. All rights reserved.
//

import Foundation


class Currency {

    var id: String = ""
    var name : String = ""
    var rate: Double = 0.0
    var localIdentifier: String = ""
    var imgFlagName : String = ""
    var imgFlagExtension : String = ""
    
    
    init(id : String, name : String, rate : Double, localId: String, flagName : String, flagExtension: String){
        
        self.id = id
        self.name = name
        self.rate = rate
        self.localIdentifier = localId
        self.imgFlagName = flagName
        self.imgFlagExtension = flagExtension
    }
    
    func convertToUSD(valueUSD : Int) -> Double {
        
        let usdConverted = self.rate * Double(valueUSD)
        return round(usdConverted*1000)/1000
    }
    

}
