//
//  MenuView.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit
import iAd
import SystemConfiguration

class MenuView: AbstractView, ADBannerViewDelegate
{
    private var desc        : UITextView!;
    private var title       : UITextView!;
    private var instructs   : UITextView!;
    private var instructImg : UIImageView!;
    private var actions     : Array<UILabel>!;
    private var fontColor   : UIColor = UIColor.blackColor();
    private var scaleFactor : CGFloat = 1;
    private var _bannerView : ADBannerView!;
    private var _adLoaded   : Bool = false;
    private var btConfig    : UIImageView!;
    private var configView  : ConfigsView!;
    private var DEFAULT_W   : CGFloat = 0;
    private var _adLoader   : UILabel!;
    private var _showActionsTimer: NSTimer!;
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        self.DEFAULT_W = UIScreen.mainScreen().applicationFrame.width;
        
        var img:UIImage! = UIImage(named: ImagesNames.Background)!;
        let imgView:UIImageView = UIImageView(image: img);
        imgView.frame = self.frame;
        self.addSubview(imgView)
        
        self.title = UITextView();
        self.title.textColor = fontColor;
        self.title.scrollEnabled = false;
        self.title.editable = false;
        self.title.selectable = false;
        self.addSubview(self.title);
        self.title.editable = false;
        
        self.desc = UITextView();
        self.desc.textColor = fontColor;
        self.desc.scrollEnabled = false;
        self.desc.editable = false;
        self.desc.selectable = false;
        self.addSubview(self.desc);
        self.desc.editable = false;
        
        self.instructs = UITextView();
        self.instructs.textColor = fontColor;
        self.addSubview(self.instructs);
        self.instructs.editable = false;
        
        if(self.width > 375)// && self.width < 414)
        {
            self.scaleFactor = 2;
        }
        
        img = UIImage(named:ImagesNames.ConfigIcon);
        img = ImageHelper.imageScaledToFit(img, sizeToFit: CGSize(width: 60, height: 60));
        btConfig = UIImageView(image: img);
        self.addSubview(btConfig);
        btConfig.alpha = 0.4;
        self.updateConfigButtonPosition(self.height);
        self.btConfigToClosedPosition();
        btConfig.addTarget(self, selector: #selector(MenuView.configsHandler));
    }
    
    private var _animating:Bool = false;
    func configsHandler()
    {
        if(_animating)
        {
            return;
        }
        
        _animating = true;
        
        if(self.configView == nil)
        {
            self.configView = ConfigsView();
            self.configView._hasPurchasedCallback = self.hideBannerHandler;
            self.addSubview(self.configView);
            self.configView.x = self.DEFAULT_W;
            //            self.width = self.configView.x + self.configView.width;
            self.configView.height = self.height;
            if(self._bannerView != nil)
            {
                self.configView.height = self._bannerView.y;
                self.bringSubviewToFront(self._bannerView);
            }
            self.bringSubviewToFront(self.btConfig);
        }
        
        if(self.configView.x == self.width)
        {
            Trace("open configs");
            
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation");
            rotateAnimation.fromValue = CGFloat(M_PI * 2.0);
            rotateAnimation.toValue = 0.0;
            rotateAnimation.duration = AnimationTime.Slow;
            self.btConfig.layer.addAnimation(rotateAnimation, forKey: nil);
            
            func completion(animated:Bool)
            {
                self._animating = false;
            }
            
            UIView.animateWithDuration(AnimationTime.Slow, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.btConfig.alpha = 1;
                self.btConfig.x = 0;
                //self.btConfig.transform = CGAffineTransformRotate(self.btConfig.transform, 0);
                }, completion: completion);
            
            UIView.animateWithDuration(AnimationTime.Slow, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.configView.x = 0;
                }, completion: nil);
            
            AudioHelper.playSound(AudioHelper.MenuOpenSound);
        }
        else if(self.configView.x == 0)
        {
            Trace("close configs");
            
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation");
            rotateAnimation.fromValue = 0.0;
            rotateAnimation.toValue = CGFloat(M_PI * 2.0);
            rotateAnimation.duration = AnimationTime.Slow;
            self.btConfig.layer.addAnimation(rotateAnimation, forKey: nil);
            
            func completion(animated:Bool)
            {
                self.configView.removeFromSuperview();
                self.configView = nil;
                self._animating = false;
                self.width = self.DEFAULT_W;
            }
            
            UIView.animateWithDuration(AnimationTime.Slow, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.btConfig.alpha = 0.4;
                self.btConfigToClosedPosition();
                }, completion:completion);
            
            UIView.animateWithDuration(AnimationTime.Slow, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.configView.x = self.DEFAULT_W;
                }, completion:nil);
            
            AudioHelper.playSound(AudioHelper.MenuOpenSound);
        }
    }
    
    private func btConfigToClosedPosition()
    {
        btConfig.x = self.DEFAULT_W - btConfig.width;
    }
    
    private func updateConfigButtonPosition(posY:CGFloat)
    {
        btConfig.y = posY - btConfig.height;
    }
    
    //-------- banner functions --------------------
    private func buildBanner()
    {
        if(PurchaseController.getInstance().hasPurchased())
        {
            Trace("user has purchased remove ads");
            return;
        }
        
        if(ConnectivityHelper.isReachable() && _bannerView != nil)
        {
            _bannerView.cancelBannerViewAction();
            _bannerView.removeFromSuperview();
            _bannerView.hidden = true;
            _bannerView.delegate = nil;
            _bannerView = nil;
        }
        
        if(_bannerView == nil)
        {
            // On iOS 6 ADBannerView introduces a new initializer, use it when available.
            if(ADBannerView.instancesRespondToSelector(#selector(ADBannerView.init(adType:))))
            {
                Trace("ADAdType banner");
                _bannerView = ADBannerView(adType: ADAdType.Banner);
            }
            else
            {
                Trace("no ADAdType");
                _bannerView = ADBannerView();
            }
            _adLoaded = false;
            _bannerView.y = self.height;
            _bannerView.delegate = self;
        }
        
        if(_adLoader == nil)
        {
            _adLoader = UILabel();
            self.addSubview(_adLoader);
        }
        self.updateLoaderText();
    }
    
    func updateLoaderText()
    {
        Trace("update loader text");
        if(!PurchaseController.getInstance().hasPurchased() && !ConnectivityHelper.isReachable())
        {
            _adLoader.text = "(FREE VERSION) AVAILABLE ONLY WHILE ONLINE.";
        }
        else
        {
            _adLoader.text = "(FREE VERSION) LOADING ADVERTISEMENT...";
        }
        
        _adLoader.font = Fonts.LightFont(FontSize.Small);
        _adLoader.sizeToFit();
        _adLoader.center.x = self.center.x;
        _adLoader.y = self.height - 90;
    }
    
    func hideAdLoader()
    {
        if(_adLoader != nil && _adLoader.alpha == 1)
        {
            Trace("hide loader");
            _adLoader.alpha = 0;
        }
    }
    
    func showBanner()
    {
        if(_bannerView == nil)
        {
            Trace("no banner will be displayed.");
            return;
        }
        
        Trace("ShowBanner");
        
        var bannerFrame:CGRect = _bannerView.frame;
        if (_bannerView.bannerLoaded)
        {
            Trace("presenting banner...");
            
            func completion(animated:Bool)
            {
                self.hideAdLoader();
            }
            self._bannerView.y = self.height;
            UIView.animateWithDuration(AnimationTime.Default, delay:0, options:[], animations: {
                self._bannerView.y = self.height - self._bannerView.height;
                self.addSubview(self._bannerView);
                self.updateConfigButtonPosition(self._bannerView.y);
                }, completion:completion);
        }
        else
        {
            Trace("banner not loaded");
        }
    }
    
    func hideBannerHandler()
    {
        Trace("hiding banner...");
        NSNotificationCenter.defaultCenter().removeObserver(self);
        self.hideAdLoader();
        
        if(_bannerView != nil)
        {
            _bannerView.cancelBannerViewAction();
            _bannerView.delegate = nil;
            
            func completion(animated:Bool)
            {
                self._bannerView.removeFromSuperview();
            }
            
            if(self._bannerView.y < self.height - self._bannerView.height)
            {
                self._bannerView.y = self.height - self._bannerView.height;
            }
            
            UIView.animateWithDuration(AnimationTime.Default, animations: {
                self._bannerView.y = self.height;
                if(self.configView != nil)
                {
                    self.configView.height = self.height;
                }
                self.updateConfigButtonPosition(self._bannerView.y);
                }, completion:completion);
        }
    }
    
    func bannerViewDidLoadAd(banner:ADBannerView)
    {
        Trace("banner Loaded");
        self.hideAdLoader();
        self.showActions();
        
        if(!_adLoaded)
        {
            _adLoaded = true;
            self.showBanner();
        }
    }
    
    func bannerView(banner:ADBannerView!, didFailToReceiveAdWithError:NSError!)
    {
        Trace("banner FAILED");
        self.buildBanner();
    }
    
    func bannerViewActionShouldBegin(banner:ADBannerView, willLeaveApplication:Bool) -> Bool
    {
        return true;
    }
    
    func bannerViewActionDidFinish(banner:ADBannerView)
    {
        Trace("bannerViewActionDidFinish");
    }
    //---------------------------------
    
    func showActions()
    {
        self.killTimer();
        
        if(self.actions != nil)
        {
            for action in self.actions
            {
                action.alpha = 1;
            }
        }
    }
    
    func setTitle(text:String)
    {
        self.title.text = text;
        self.title.font = Fonts.LightFont(FontSize.Big * self.scaleFactor);
        self.title.textAlignment = NSTextAlignment.Center;
        self.title.backgroundColor = UIColor.clearColor();
        self.title.sizeToFit();
        self.title.width = self.width - 10;
        self.title.center = self.center;
        self.title.y = self.center.y - (self.height * 0.41);
        if(self.height <= 480)
        {
            self.title.y -= 15;
        }
    }
    
    func setDescription(text:String)
    {
        self.desc.text = text;
        self.desc.font = Fonts.LightFont(FontSize.Default * self.scaleFactor);
        self.desc.textAlignment = NSTextAlignment.Center;
        self.desc.backgroundColor = UIColor.clearColor();
        self.desc.sizeToFit();
        self.desc.width = self.width - 10;
        self.desc.center = self.center;
        self.desc.y = self.title.y + self.title.height - 10;
    }
    
    func setInstructions(scoreToLifeUp:Int, scoreToLevelUp:Int)
    {
        let fitSize:CGSize = CGSize(width: self.frame.size.width + 40, height: self.frame.size.height);
        let image:UIImage! = ImageHelper.imageScaledToFit(UIImage(named: ImagesNames.Instructions), sizeToFit: fitSize);
        self.instructImg = UIImageView(image: image);
        //        self.instructImg.alpha = 0;
        self.addSubview(self.instructImg);
        self.instructImg.center = self.center;
        self.instructImg.y += 10;
        
        self.instructs.text = "";
        self.instructs.font = Fonts.DefaultFont(FontSize.Tiny * self.scaleFactor);
        self.instructs.textAlignment = NSTextAlignment.Center;
        self.instructs.backgroundColor = UIColor.clearColor();
        self.instructs.sizeToFit();
        self.instructs.width = self.width - 10;
        self.instructs.center = self.center;
        self.instructs.y = self.instructImg.y + self.instructImg.height - 45;
        self.instructs.alpha = 0.5;
    }
    
    func setGameOver()
    {
        var image:UIImageView = UIImageView(image: UIImage(named: ImagesNames.Podium)!);
        self.addSubview(image);
        image.center = self.center;
        var lastY:CGFloat = 0;
        if(self.height <= 480)
        {
            image.y += 15;
        }
        lastY = image.y;
        image.addTarget(self, selector: #selector(MenuView.openGameCenter(_:)));
        
        //---fb
        image = UIImageView(image: UIImage(named: ImagesNames.FBIcon)!);
        image.alpha = 0;
        self.addSubview(image);
        image.center = self.center;
        UIView.animateWithDuration(AnimationTime.Default, delay: 2, options: [], animations: {
            image.x -= image.width * 1.6;
            image.alpha = 1;
            }, completion: nil);
        
        image.y = lastY;
        image.addTarget(self, selector: #selector(MenuView.openFBHandler(_:)));
        
        
        //---tt
        image = UIImageView(image: UIImage(named: ImagesNames.TTIcon)!);
        image.alpha = 0;
        self.addSubview(image);
        image.center = self.center;
        UIView.animateWithDuration(AnimationTime.Default, delay: 2, options: [], animations: {
            image.x += image.width * 1.6;
            image.alpha = 1;
            }, completion: nil);
        image.y = lastY;
        image.addTarget(self, selector: #selector(MenuView.openTTHandler(_:)));
        
    }
    
    func openGameCenter(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        Trace("MenuView -> MenuView -> open game center");
        GameCenterController.loadLeaderboard();
    }
    
    func openFBHandler(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
        shareBuilder(SocialController.facebookType);
    }
    
    func openTTHandler(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
        shareBuilder(SocialController.twitterType);
    }
    
    private func shareBuilder(type:String)
    {
        SocialController.getInstance().share(type, text:"Level achieved: \(AppDelegate.getInstance().gameController.scene.currentLevel()) (\(AppDelegate.getInstance().gameController.scene.currentScore()) points) #CarRacingChallenge", url:Routes.ITUNES_URL);
    }
    
    func setAction(text:String!, target:AnyObject, selector:Selector)
    {
        if(self.actions == nil)
        {
            self.actions = Array<UILabel>();
        }
        
        let newAction:UILabel = UILabel();
        newAction.textColor = fontColor;
        newAction.alpha = 0;
        self.addSubview(newAction);
        self.actions.append(newAction);
        
        newAction.text = text;
        newAction.font = Fonts.DefaultFont(FontSize.Medium * self.scaleFactor);
        newAction.textAlignment = NSTextAlignment.Center;
        newAction.sizeToFit();
        newAction.width = self.width - 10;
        newAction.center = self.center;
        newAction.addTarget(target, selector: selector);
        
        let totalHeight:CGFloat = ((newAction.height + 10) * self.actions.count.floatValue);
        for i in 0 ..< self.actions.count
        {
            let action:UILabel = self.actions[i];
            
            if(self.height <= 480)
            {
                action.y = (self.height) * 0.88 - totalHeight + ((action.height + 10) * i.floatValue);
            }
            else
            {
                action.y = (self.height) * 0.82 - totalHeight + ((action.height + 20) * i.floatValue);
            }
        }
    }
    
    override func present(completion: ((animated: Bool) -> Void)!)
    {
        self.bringSubviewToFront(self.btConfig);
        
        if(PurchaseController.getInstance().hasPurchased())
        {
            self.showActions();
        }
        else
        {
            self.buildBanner();
            _showActionsTimer = Utils.delayedCall(7, target: self, selector: #selector(MenuView.showActions), repeats: false);
        }
        
        super.present(completion);
    }
    
    func killTimer()
    {
        if(_showActionsTimer != nil)
        {
            Trace("kill actions timer");
            _showActionsTimer.invalidate();
            _showActionsTimer = nil;
        }
    }
    
    override func dismiss(completion: ((animated: Bool) -> Void)!)
    {
        Trace("dismiss menu");
        NSNotificationCenter.defaultCenter().removeObserver(self);
        
        self.killTimer();
        
        if(self._bannerView == nil)
        {
            super.dismiss(completion);
            return;
        }
        
        func completion(animated:Bool)
        {
            self._bannerView.removeFromSuperview();
            super.dismiss(completion);
        }
        
        if(self._bannerView.y < self.height - self._bannerView.height)
        {
            self._bannerView.y = self.height - self._bannerView.height;
        }
        
        UIView.animateWithDuration(AnimationTime.Default, animations: {
            self._bannerView.y = self.height;
            self.updateConfigButtonPosition(self._bannerView.y);
            }, completion:completion);
    }
    
    func disableAction()
    {
        for i in 0 ..< self.actions.count
        {
            let action:UILabel = self.actions[i];
            action.gestureRecognizers?.removeAll(keepCapacity: false);
        }
    }
}