//
//  PurchaseController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 27/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import StoreKit

private var _instance : PurchaseController!;
private var _hasPurchased: Bool = false;

class PurchaseController:NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    private var productsIDs:NSDictionary!;
    
    class func getInstance() -> PurchaseController
    {
        if(_instance == nil)
        {
            _instance = PurchaseController();
        }
        return _instance;
    }
    
    override init()
    {
        super.init();
        
        if let url:NSURL = NSBundle.mainBundle().URLForResource("Products",  withExtension:"plist")
        {
            if let dict:NSDictionary = NSDictionary(contentsOfURL:url)
            {
                self.productsIDs = dict;
            }
        }
        
        _hasPurchased = DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyAds);
    }
    
    func hasPurchased() -> Bool
    {
        return _hasPurchased;
    }
    
    func hasPurchased(value:Bool)
    {
        DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyAds, value: value);
        _hasPurchased = value;
    }
    
    func userCanPurchase() -> Bool
    {
        return SKPaymentQueue.canMakePayments();
    }
    
    func buyRemoveAds()
    {
        if(self.productsIDs == nil)
        {
            Trace.log("Remove Ads handler ERROR");
            return;
        }
        
        Trace.log("Remove Ads handler");
        
        Utils.showAlert(title: nil, message: "please wait...", action: nil, completion: nil);
        
        if let id = self.productsIDs.valueForKey("remove_ads") as? String
        {
            Trace.log("validating Remove Ads ID:\(id)...");
            self.validateProductIdentifiers([id]);
        }
        else
        {
            Trace.log("Remove Ad ID not found");
            Utils.showAlert(title: "Remove Ad", message: "Sorry. Something went wrong. Please try again.", completion: nil);
        }
    }
    
    private func validateProductIdentifiers(productIdentifiers:Set<NSObject>!)
    {
        var productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers);
        productsRequest.delegate = self;
        productsRequest.start();
    }
    
    
    //---------------- observers --------------
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!)
    {
        for obj in transactions
        {
            if let transaction = obj as? SKPaymentTransaction
            {
                Trace.log("transaction state \(transaction.transactionState.rawValue)");
                switch (transaction.transactionState)
                {
                    // Call the appropriate custom method for the transaction state.
                case SKPaymentTransactionState.Purchasing:
                    Trace.log("Purchasing");
                    Utils.showAlert(title: nil, message: "Please Wait...", action: nil, cancel: nil, completion: nil);
                    break;
                case SKPaymentTransactionState.Deferred:
                    Trace.log("Deferred");
//                    Utils.showAlert(title: "Purchase canceled", message: nil, action: nil, cancel: nil, completion: nil);
//                    SKPaymentQueue.defaultQueue().removeTransactionObserver(self);
                    break;
                case SKPaymentTransactionState.Failed:
                    Trace.log("Failed");
//                    Utils.showAlert(title: "Purchase Failed", message: "Your purchase was not confirmed.", action: nil, cancel: "OK", completion: nil);
//                    SKPaymentQueue.defaultQueue().removeTransactionObserver(self);
                    break;
                case SKPaymentTransactionState.Purchased:
                    Trace.log("Purchased");
                    Utils.hideAlert(nil);
//                    Utils.showAlert(title: "Purchase Confirmed", message: "Thank you!", action: "OK", cancel: nil, completion: nil);
//                    SKPaymentQueue.defaultQueue().removeTransactionObserver(self);
                    NSNotificationCenter.defaultCenter().postNotificationName(Events.AdsPurchased, object:self);
                    break;
                case SKPaymentTransactionState.Restored:
                    Trace.log("Restored");
                    Utils.hideAlert(nil);
//                    Utils.showAlert(title: "Purchase Restored", message: "Thank you!", action: "OK", cancel: nil, completion: nil);
//                    SKPaymentQueue.defaultQueue().removeTransactionObserver(self);
                    NSNotificationCenter.defaultCenter().postNotificationName(Events.AdsPurchased, object:self);
                    break;
                default:
                    // For debugging
                    Utils.hideAlert(nil);
                    Trace.log("Unexpected transaction state \(transaction.transactionState.rawValue)");
//                    SKPaymentQueue.defaultQueue().removeTransactionObserver(self);
                    break;
                }
            }
        }
    }
    
    @objc func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!)
    {
        if let valid:NSArray = response.products
        {
            for validIdentifier in valid
            {
                if let prod = validIdentifier as? SKProduct
                {
                    var numberFormatter:NSNumberFormatter = NSNumberFormatter();
                    numberFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4;
                    numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle;
                    numberFormatter.locale = prod.priceLocale;
                    var formattedPrice:NSString = numberFormatter.stringFromNumber(prod.price)!;
                    
                    func confirm()
                    {
                        Trace.log("user confirmed purchase");
                        SKPaymentQueue.defaultQueue().addTransactionObserver(self);
                        
                        var payment:SKMutablePayment = SKMutablePayment(product: prod);
                        payment.quantity = 1;
                        SKPaymentQueue.defaultQueue().addPayment(payment);
                    }
                    
                    confirm();
                    break;
                }
            }
            
            Trace.log("valid products count:\(valid.count)");
        }
        
        if let invalid:NSArray = response.invalidProductIdentifiers
        {
            for invalidIdentifier in invalid
            {
                
            }
            
            Trace.log("invalid products count:\(invalid.count)");
        }
    }
}