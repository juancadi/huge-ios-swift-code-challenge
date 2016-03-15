//
//  HugeCurrencyConverterTests.swift
//  HugeCurrencyConverterTests
//
//  Created by JUAN ANDRÉS CÁRDENAS DIAZ on 13/03/16.
//  Copyright © 2016 JUAN ANDRÉS CÁRDENAS DIAZ. All rights reserved.
//

import XCTest
import Alamofire
import SwiftyJSON
@testable import HugeCurrencyConverter

class HugeCurrencyConverterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
   
    func testNetworkAvailability(){
        
        let network = Network()
        XCTAssertEqual(network.isConnectedToNetwork(), true, "Test for check the network availability works!")
        
    }
    
    func testConvertCurrencyToUSD(){
        
        let currencyModel:Currency = Currency(id: "GBP", name: "UK Pounds (GBP)", rate: 0.5, localId: "en_GB", flagName: "uk-flag", flagExtension: ".png")
        
        XCTAssertEqual(currencyModel.convertToUSD(10), 5.0, "Test for check the convertToUSD currency works!")
    }
    
    func testLocalCurrencyFormat(){
    
        let testNumber : Double = 100000000
         XCTAssertEqual(testNumber.asLocaleCurrency("es_CO"), "$100.000.000", "Test for check currency local format works!")
    
    }
    
    func testCurrencyHttpRequest(){
        
        let currencyUrl = "https://api.fixer.io/latest"
        let currencyParameters = [
            "base": "USD"
        ]
    
        Alamofire.request(.GET, currencyUrl, parameters: currencyParameters)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                    
                case .Success:
                    
                    let jsonCurrency = JSON(response.result.value!)
                    
                    XCTAssertEqual(jsonCurrency["base"].stringValue, "USD", "Test for check the Http Request works!")
                    
                case .Failure(let error):
                    print(error)
                    
                }
        }
    
    
    
    }
    
}
