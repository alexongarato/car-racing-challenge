//
//  PurchaseController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 27/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import StoreKit

private var _instance           : PurchaseController!;
private var _hasPurchased       : Bool = false;
private var _transactionType    : Int = -1;
private var _productsRequest    : SKProductsRequest!;

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
        
        _hasPurchased = hasPurchased();
    }
    
    func hasPurchased() -> Bool
    {
        return (Configs.FULL_VERSION_MODE) ? true : DataProvider.getInteger(SuiteNames.SuiteConfigs, key: SuiteNames.KeyAds) >= 2;
    }
    
    func hasPurchased(value:Bool)
    {
        DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyAds, value: (value == true) ? 2 : 0);
        _hasPurchased = value;
    }
    
    func userCanPurchase() -> Bool
    {
        return SKPaymentQueue.canMakePayments();
    }
    /*
    func showDefaultPurchaseMessage(completion:(()->Void)!)
    {
        AlertController.getInstance().showAlert(title: "FREE VERSION", message: "It's Only available while online.\nTry the full version now!", action: "OK", completion: completion);
    }
    */
    func buyRemoveAds(tryRestore:Bool)
    {
        if(self.productsIDs == nil)
        {
            print("Remove Ads handler ERROR");
            return;
        }
        
        _transactionType = tryRestore ? 1 : 0;
        
        print("Remove Ads handler");
        
        if let id = self.productsIDs.valueForKey("remove_ads") as? String
        {
            print("validating Remove Ads ID:\(id)...");
            AlertController.getInstance().showAlert(nil, message: "please wait...", action: nil, completion:nil);// {
                self.validateProductIdentifiers([id]);
//            });
        }
        else
        {
            print("Remove Ad ID not found");
            AlertController.getInstance().showAlert("Remove Ad", message: "Sorry. Something went wrong. Please try again.", completion: nil);
        }
    }
    
    private func validateProductIdentifiers(productIdentifiers:Set<String>!)
    {
        if(!ConnectivityHelper.isReachable())
        {
            ConnectivityHelper.showDefaultOfflineMessage();
            return;
        }
        
        if(_productsRequest != nil)
        {
            _productsRequest.cancel();
            _productsRequest.delegate = nil;
            _productsRequest = nil;
        }
        
        _productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers);
        _productsRequest.delegate = self;
        _productsRequest.start();
        
        //calls productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!)
    }
    
    
    //---------------- observers --------------
    @objc func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
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
                    
                    func startPayment()
                    {
                        SKPaymentQueue.defaultQueue().addTransactionObserver(self);
                        
                        AlertController.getInstance().hideAlert(nil);
                        
                        if(_transactionType == 0)
                        {
                            print("starting payment process...");
                            let payment:SKMutablePayment = SKMutablePayment(product: prod);
                            payment.quantity = 1;
                            SKPaymentQueue.defaultQueue().addPayment(payment);
                        }
                        else if(_transactionType == 1)
                        {
                            print("starting restore payment process...");
                            SKPaymentQueue.defaultQueue().restoreCompletedTransactions();
                        }
                        
                        _transactionType = -1;
                    }
                    
                    _productsRequest.delegate = nil;
                    startPayment();
                    return;
                }
                else
                {
                    print("valid product failed");
                }
            }
            
            print("valid products count:\(valid.count)");
        }
        
        if let invalid:NSArray = response.invalidProductIdentifiers
        {
            for _ in invalid
            {
                AlertController.getInstance().showAlert("Error", message: "The product requested is currently unavailable. Try again later.", action: "OK", completion: nil);
                break;
            }
            
            print("invalid products count:\(invalid.count)");
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        
        var failed:Bool = false;
        var purchased:Bool = false;
        
        print("paymentQueue updateTransactions");
        
        if let prodID = self.productsIDs.valueForKey("remove_ads") as? String
        {
            for transaction in transactions
            {
                print("product: \(transaction.payment.productIdentifier), state \(transaction.transactionState.rawValue)");
                
                if(transaction.payment.productIdentifier == prodID)
                {
                    switch (transaction.transactionState)
                    {
                    case SKPaymentTransactionState.Purchasing:
                        print("Purchasing");
                        
                    case SKPaymentTransactionState.Deferred:
                        print("Deferred");
                        failed = true;
                        AlertController.getInstance().hideAlert(nil);
                    case SKPaymentTransactionState.Failed:
                        print("Failed");
//                                failed = true;
                        AlertController.getInstance().hideAlert(nil);
                        
                    case SKPaymentTransactionState.Purchased:
                        print("Purchased");
                        purchased = true;
                        break;
                    case SKPaymentTransactionState.Restored:
                        print("Restored");
                        purchased = true;
                        break;
                    }
                }
            }
        }
        else
        {
            AlertController.getInstance().showAlert("Error", message: "Oops!\nAn error occurred.\nCode:001", action: "OK");
        }
        
        if(failed)
        {
            AlertController.getInstance().showAlert("Failed", message: "\nPurchase not completed.\n\nTry again later.\n", action: "OK");
        }
        
        if(purchased)
        {
            AlertController.getInstance().hideAlert(nil);
            NSNotificationCenter.defaultCenter().postNotificationName(Events.AdsPurchased, object:self);
            return;
        }
    }
  /*
    func paymentQueue(queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        
    }
 */
}