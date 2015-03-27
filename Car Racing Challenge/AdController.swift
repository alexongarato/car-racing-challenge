//
//  AdController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 3/26/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

/*
import Foundation
import iAd
import UIKit

private var _instance : AdController!;

class AdController:UIViewController, ADInterstitialAdDelegate
{
    private var interstitial    : ADInterstitialAd!;
    private var container       : UIView!;
    
    class func getInstance() -> AdController
    {
        if(_instance == nil)
        {
            _instance = AdController();
        }
        
        return _instance;
    }
    
    //----- private
    func showBanner(view:UIView!)
    {
        Trace.log("AdController -> presenting...");
        
        if(interstitial == nil)
        {
            Trace.log("AdController -> banner not loaded");
            return;
        }
        
        if(self.container != nil)
        {
            self.container.removeFromSuperview();
            self.container = nil;
        }
        
        if (interstitial.loaded)
        {
            self.container = view;
            (UIApplication.sharedApplication().delegate as! AppDelegate).gameController.applicationWillResignActive();
            interstitial.presentInView(self.container);
        }
        else
        {
            Trace.log("AdController -> banner not loaded");
        }
    }
    
    func cycleInterstitial()
    {
        Trace.log("AdController -> recycling...");
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
        Trace.log("AdController -> banner closed");
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameController.applicationDidBecomeActive();
        self.cycleInterstitial();
    }
        
    // This method will be invoked when an error has occurred attempting to get advertisement content.
    // The ADError enum lists the possible error codes.
    @objc func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!)
    {
        Trace.log("AdController -> banner error");
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameController.applicationDidBecomeActive();
        self.cycleInterstitial();
    }
}
*/