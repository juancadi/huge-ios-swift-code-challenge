//
//  ViewController.swift
//  HugeCurrencyConverter
//
//  Created by JUAN ANDRÉS CÁRDENAS DIAZ on 13/03/16.
//  Copyright © 2016 JUAN ANDRÉS CÁRDENAS DIAZ. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class ViewController: UIViewController, UITextFieldDelegate, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var txtUSD: UITextField!
    @IBOutlet weak var currencyItemsContentView: UIView!
    @IBOutlet weak var contentScrollView: UIView!
    @IBOutlet weak var contentScrollWidth: NSLayoutConstraint!
    
   
    var hScroll : CGFloat = 0
    var wScroll : CGFloat = 0
    var networkUtil : Network!
    var currencyData : [Currency]!
    var exchangeRatesAvailables : Bool = false
    var activityIndicatorView: ActivityIndicatorView!

    let currencyUrl = "https://api.fixer.io/latest"
    let currencyParameters = [
        "base": "USD"
    ]

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        currencyData = [
            Currency(id: "GBP", name: "UK Pounds (GBP)", rate: 0.0, localId: "en_GB", flagName: "uk-flag", flagExtension: ".png"),
            Currency(id: "EUR", name: "EU Euro (EUR)", rate: 0.0, localId: "es_ES", flagName: "european-flag", flagExtension: ".png"),
            Currency(id: "JPY", name: "Japan Yen ­ (JPY)", rate: 0.0, localId: "ja_JP", flagName: "japan-flag", flagExtension: ".png"),
            Currency(id: "BRL", name: "Brazil Reais ­ (BRL)", rate: 0.0, localId: "pt_BR", flagName: "brazil-flag", flagExtension: ".png")
        ]
        
        
        txtUSD.delegate = self
        barChartView.delegate = self
        barChartView.hidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Hide the keyboard when the key "Done" is pressed
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    //Hide the keyboard when the view in background is tapped
    @IBAction func backgroundTap(sender: UIControl) {
        
        txtUSD.resignFirstResponder()
    }
    
    //Logic implemented to get an http response, process it and update the UI with the currency convertions
    @IBAction func convertUSD(sender: AnyObject) {
        
        if !txtUSD.text!.isEmpty
        {
            
            if exchangeRatesAvailables
            {
                
                loadCurrencyItems(currencyData)
                
            }else{
                
                networkUtil = Network()
                
                if networkUtil.isConnectedToNetwork(){
                    
                    self.activityIndicatorView = ActivityIndicatorView(title: "In Progress...", center: self.view.center)
                    self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
                    self.activityIndicatorView.startAnimating()
                    
                    //Getting http response from https://api.fixer.io/latest
                    Alamofire.request(.GET, currencyUrl, parameters: currencyParameters)
                        .validate(statusCode: 200..<300)
                        .responseJSON { response in
                            
                            switch response.result {
                                
                            case .Success:
                                
                                if let value = response.result.value {
                                    
                                    let jsonCurrency = JSON(value)
                                    self.barChartView.descriptionText = jsonCurrency["date"].stringValue
                                    
                                    for var i = 0; i < self.currencyData.count; i++ {
                                        
                                        self.currencyData[i].rate = jsonCurrency["rates"][self.currencyData[i].id].doubleValue
                                        
                                    }
                                    
                                    self.exchangeRatesAvailables = true
                                    self.activityIndicatorView.stopAnimating()
                                    
                                    //Updating UI from background process
                                    dispatch_async(dispatch_get_main_queue()) {
                                        
                                        self.barChartView.hidden = false
                                        self.showChart(self.currencyData)
                                        self.loadCurrencyItems(self.currencyData)
                                        
                                    }
                                    
                                }
                                
                                
                            case .Failure(let error):
                                print(error)
                                
                            }
                    }
                    
                }else {
                    
                    let networkAlert = UIAlertController(title: "Ooops!", message: "Internet connection is not detected, please check it and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    networkAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(networkAlert, animated: true, completion: nil)
                    
                }
                
            }
            
        }else{
        
            let fieldEmptyAlert = UIAlertController(title: "Ooops!", message: "You should enter a value to process the currency convertion.", preferredStyle: UIAlertControllerStyle.Alert)
            fieldEmptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(fieldEmptyAlert, animated: true, completion: nil)
        
        }
        
        
    }
    
    
    //Configuring and setting Bar Chart with the currency convertion rates
    func showChart(currencyData: [Currency]) {
        
        barChartView.noDataText = "Please enter any number of dollar bills, to calculate the exchange rate."
        var dataEntries: [BarChartDataEntry] = []
        var xLabels : [String]! = [String]()
        
        for i in 0..<currencyData.count {
            let dataEntry = BarChartDataEntry(value: currencyData[i].rate, xIndex: i)
            dataEntries.append(dataEntry)
            xLabels.append(currencyData[i].id)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Exchange Rate")
        let chartData = BarChartData(xVals: xLabels, dataSet: chartDataSet)
        barChartView.data = chartData
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartView.pinchZoomEnabled = false
        barChartView.data!.setDrawValues(false)

        chartDataSet.colors = ChartColorTemplates.colorful()
        
    }
    
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        print("\(entry.value) in \(currencyData[entry.xIndex])")
    }
    
    //Showing additional information about currency convertion values
    func loadCurrencyItems(items : [Currency]){
        
        hScroll = currencyItemsContentView.bounds.height
        wScroll = hScroll * 2
        
        contentScrollWidth.constant = wScroll * CGFloat(items.count)
        
        
        for var i=0 ; i<items.count; i++ {
            
            //Building a CustomView an adding it to the ContentView
            let cellCurrencyItem = CurrencyItemView.init(frame: CGRect(x: wScroll*CGFloat(i), y: 0, width: wScroll, height: hScroll))
            cellCurrencyItem.lblTitle.text = items[i].name
            cellCurrencyItem.lblRate.text = "Rate: \(items[i].rate.asLocaleCurrency(items[i].localIdentifier))"
            cellCurrencyItem.lblResult.text = "Result: \(items[i].convertToUSD(Int(self.txtUSD.text!)!)) USD"
            cellCurrencyItem.imgFlag.image = UIImage(named: "\(items[i].imgFlagName)")
            cellCurrencyItem.alpha = 0
            
            self.contentScrollView.addSubview(cellCurrencyItem)
            cellCurrencyItem.fadeIn()
            
        }
        
        
    }


}

