//
//  iAdController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 3/26/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import iAd
import UIKit

private var _instance : iAdController!;

class iAdController:UIViewController, ADInterstitialAdDelegate
{
    private var interstitial : ADInterstitialAd!;
    
    class func getInstance() -> iAdController
    {
        if(_instance == nil)
        {
            _instance = iAdController();
        }
        
        return _instance;
    }
    
    func presentInterlude(containerView: UIView!)
    {
        Trace.log("presenting...");
        
        // If the interstitial managed to load, then we'll present it now.
        if (interstitial.loaded)
        {
            (UIApplication.sharedApplication().delegate as! AppDelegate).gameController.applicationWillResignActive();
            interstitial.presentInView(containerView);
            
            var closeButton:UILabel = UILabel();
            closeButton.text = "close";
            closeButton.textColor = UIColor.whiteColor();
            closeButton.sizeToFit();
            containerView.addSubview(closeButton);
            closeButton.x = containerView.width - closeButton.width - 10;
            closeButton.y = 10;
            closeButton.userInteractionEnabled = false;
//            closeButton.addTarget(self, selector: Selector("closeBanner"));
        }
    }
    
    func closeBanner()
    {
        if(interstitial != nil)
        {
            interstitial.cancelAction();
            interstitial.delegate = nil;
            interstitial = nil;
        }
    }
    
    func cycleInterstitial()
    {
        Trace.log("recycling...");
        
        // Clean up the old interstitial...
        if(interstitial != nil)
        {
            interstitial.delegate = nil;
            interstitial = nil;
        }
        
        interstitial = ADInterstitialAd();
        interstitial.delegate = self;
    }
    
    
    // When this method is invoked, the application should remove the view from the screen and tear it down.
    // The content will be unloaded shortly after this method is called and no new content will be loaded in that view.
    // This may occur either when the user dismisses the interstitial view via the dismiss button or
    // if the content in the view has expired.
    @objc func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!)
    {
        self.cycleInterstitial();
        Trace.log("banner closed");
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameController.applicationDidBecomeActive();
    }
    
    
    // This method will be invoked when an error has occurred attempting to get advertisement content.
    // The ADError enum lists the possible error codes.
    @objc func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!)
    {
        self.cycleInterstitial();
        Trace.log("banner error");
    }
}