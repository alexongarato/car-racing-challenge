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
    
    override func didMoveToSuperview()
    {
//        self.frame = UIScreen.mainScreen().applicationFrame;

        super.didMoveToSuperview();
        var img:UIImage! = UIImage(named: ImagesNames.Background)!;
        var imgView:UIImageView = UIImageView(image: img);
        imgView.frame = self.frame;
        self.addSubview(imgView)
        
        self.title = UITextView();
        self.title.textColor = fontColor;
        self.title.scrollEnabled = false;
        self.title.editable = false;
        self.title.selectable = false;
        self.addSubview(self.title);
        self.title.editable = false;
//        self.title.alpha = 0;
        
        self.desc = UITextView();
        self.desc.textColor = fontColor;
        self.desc.scrollEnabled = false;
        self.desc.editable = false;
        self.desc.selectable = false;
        self.addSubview(self.desc);
        self.desc.editable = false;
//        self.desc.alpha = 0;
        
        self.instructs = UITextView();
        self.instructs.textColor = fontColor;
        self.addSubview(self.instructs);
        self.instructs.editable = false;
        
        if(self.width > 375)// && self.width < 414)
        {
            self.scaleFactor = 2;
        }
        
//        if(self.width > 414)
//        {
//            self.scaleFactor = 3;
//        }
        
        self.buildBanner();
        
        img = UIImage(named:ImagesNames.ConfigIcon);
        img = ImageHelper.imageScaledToFit(img, sizeToFit: CGSize(width: 30 * self.scaleFactor, height: 30 * self.scaleFactor));
        btConfig = UIImageView(image: img);
        self.addSubview(btConfig);
        btConfig.alpha = 0.8;
        self.updateConfigButtonPosition(self.height);
        btConfig.addTarget(self, selector: Selector("configsHandler"));
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
            self.addSubview(self.configView);
            self.configView.x = self.width;
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
            
            UIView.animateWithDuration(AnimationTime.Slow, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.configView.x = 0;
                }, completion: completion);
            
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
            }
            
            UIView.animateWithDuration(AnimationTime.Slow, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.configView.x = self.width;
                }, completion:completion);
            
            AudioHelper.playSound(AudioHelper.MenuOpenSound);
        }
    }
    
    private func updateConfigButtonPosition(posY:CGFloat)
    {
        btConfig.x = self.width - (btConfig.width * 1.5);
        btConfig.y = posY - (btConfig.height * 1.5);
    }
    
    //-------- banner functions --------------------
    private func buildBanner()
    {
        if(PurchaseController.getInstance().hasPurchased())
        {
            Trace("user has purchased remove ads");
            return;
        }
        
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if(ADBannerView.instancesRespondToSelector(Selector("initWithAdType:")))
        {
            Trace("ADAdType banner");
            _bannerView = ADBannerView(adType: ADAdType.Banner);
        }
        else
        {
            Trace("no ADAdType");
            _bannerView = ADBannerView();
        }
        
        _bannerView.y = self.height;
        _bannerView.delegate = self;
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
            Trace("banner loaded");
            
            self._bannerView.y = self.height;
            UIView.animateWithDuration(AnimationTime.Default, animations: {
                self._bannerView.y = self.height - self._bannerView.height;
                self.addSubview(self._bannerView);
                self.updateConfigButtonPosition(self._bannerView.y);
            });
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("hideBannerHandler"), name: Events.removeAds, object: nil);
        }
        else
        {
            Trace("banner not loaded");
        }
    }
    
    func hideBannerHandler()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        if(_bannerView != nil)
        {
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
                self.updateConfigButtonPosition(self._bannerView.y);
                }, completion:completion);
        }
    }
    
    func bannerViewDidLoadAd(banner:ADBannerView)
    {
        Trace("bannerViewDidLoadAd");
        if(!_adLoaded)
        {
            _adLoaded = true;
            self.showBanner();
        }
    }
    
    func bannerView(banner:ADBannerView!, didFailToReceiveAdWithError:NSError!)
    {
        Trace("didFailToReceiveAdWithError");
    }
    
    func bannerViewActionShouldBegin(banner:ADBannerView, willLeaveApplication:Bool) -> Bool
    {
        Trace("bannerViewActionShouldBegin");
        return true;
    }
    
    func bannerViewActionDidFinish(banner:ADBannerView)
    {
        Trace("bannerViewActionDidFinish");
    }
    //---------------------------------
    
    
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
        var fitSize:CGSize = CGSize(width: self.frame.size.width + 40, height: self.frame.size.height);
        var image:UIImage! = ImageHelper.imageScaledToFit(UIImage(named: ImagesNames.Instructions), sizeToFit: fitSize);
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
        var image:UIImage! = UIImage(named: ImagesNames.Podium);
        var podium:UIImageView = UIImageView(image: image);
//        if(self.scaleFactor > 1)
//        {
//            podium.scale(1.5);
//        }
        self.addSubview(podium);
        podium.center = self.center;
        if(self.height > 480)
        {
            podium.y -= 10;
        }
        else
        {
            podium.y += 25;
        }
        podium.addTarget(self, selector: Selector("openGameCenter:"));
    }
    
    func openGameCenter(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        Trace("MenuView -> MenuView -> open game center");
        GameCenterController.loadLeaderboard();
    }
    
    func setAction(text:String!, target:AnyObject, selector:Selector)
    {
        if(self.actions == nil)
        {
            self.actions = Array<UILabel>();
        }
        
        var newAction:UILabel = UILabel();
        newAction.textColor = fontColor;
        self.addSubview(newAction);
        self.actions.append(newAction);
        
        newAction.text = text;
        newAction.font = Fonts.DefaultFont(FontSize.Medium * self.scaleFactor);
        newAction.textAlignment = NSTextAlignment.Center;
        newAction.sizeToFit();
        newAction.width = self.width - 10;
        newAction.center = self.center;
        newAction.addTarget(target, selector: selector);
        
        var totalHeight:CGFloat = ((newAction.height + 10) * self.actions.count.floatValue);
        for(var i:Int = 0; i < self.actions.count; i++)
        {
            var action:UILabel = self.actions[i];
            
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
        super.present(completion);
        self.bringSubviewToFront(self.btConfig);
    }
    /*
    override func present(completion: ((animated: Bool) -> Void)!)
    {
        func addAnima(target:UIView, delay:NSTimeInterval, completion: ((animated: Bool) -> Void)!)
        {
            target.y += 5;
            UIView.animateWithDuration(AnimationTime.Default, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                target.y -= 5;
                target.alpha = 1;
                }, completion: completion);
        }
        super.present({ (animated) -> Void in
            var del:NSTimeInterval = 0;
            addAnima(self.title, del, nil);
            del += 0.1;
            addAnima(self.desc, del, nil);
            del += 0.1;
            addAnima(self.instructImg, del, nil);
            del += 0.1;
            for(var i:Int = 0; i < self.actions.count; i++)
            {
                var action:UILabel = self.actions[i];
                addAnima(action, del, nil);
                del += 0.1;
            }
            addAnima(self.btConfig, del, nil);
        });
    }*/
    
    override func dismiss(completion: ((animated: Bool) -> Void)!)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        
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
        for(var i:Int = 0; i < self.actions.count; i++)
        {
            var action:UILabel = self.actions[i];
            action.gestureRecognizers?.removeAll(keepCapacity: false);
        }
    }
}