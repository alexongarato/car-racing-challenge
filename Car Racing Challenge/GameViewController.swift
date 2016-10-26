//
//  GameViewController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate
{
    var scene                   : GameScene!;
    var sceneView               : SKView!;
    var menuView                : MenuView!;
    var statusView              : GameStatusView!;
    var pauseArea               : UIView!;
    var snapshotView            : UIImageView!;
    var showResumeOnStartUp     : Bool = false;
    var touchAreasImgView       : UIImageView!;
    fileprivate var _bestScore      : NSInteger = 0;
    
    override func viewDidLoad()
    {
        //------ INIT DATA ------
        if(!DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyFirstTime))
        {
            DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeySound, value: true);
            setBestScore(0);
            DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyAds, value: false);
            DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyFirstTime, value: true);
        }
        //------
        
        
        
        AppDelegate.getInstance().gameController = self;
        AlertController.getInstance().build(self);
        
        //var purchased:Bool = PurchaseController.getInstance().hasPurchased();
        
        sceneView = SKView();
        sceneView.frame = self.view.frame;
        
        sceneView.ignoresSiblingOrder = false;
        self.view.addSubview(sceneView);
        
        //sceneView.showsFPS = Configs.DEBUG_MODE;
        //sceneView.showsNodeCount = Configs.DEBUG_MODE;
        
        super.viewDidLoad();
        
        self.scene = GameScene();
        scene.size = UIScreen.main.applicationFrame.size;
        scene.updateStatusHandler = self.updateGameStatusHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        sceneView.presentScene(scene);
        
        print("GameViewController -> \(scene.size.description as String)");
        
        self.statusView = GameStatusView();
        self.view.addSubview(self.statusView);
        
        self.pauseArea = UIView();
        self.pauseArea.frame = self.view.frame;
        self.pauseArea.width = self.view.width / 3;
        self.pauseArea.center.x = self.view.center.x;
        self.pauseArea.height = self.pauseArea.height * 0.8;
//        self.pauseArea.backgroundColor = UIColor.redColor();
//        self.pauseArea.alpha = 0.2;
        self.pauseArea.backgroundColor = UIColor.clear;
        self.pauseArea.addTarget(self, selector: #selector(GameViewController.pauseGameHandler));
        self.view.addSubview(self.pauseArea);
        
        
        scene.lifeUpHandler = self.statusView.showSuccessAnimation;
        scene.lifeDownHandler = self.statusView.showErrorAnimation;
        
        let data:NSString = DataProvider.getString(SuiteNames.SuiteBestScore, key: SuiteNames.KeyBestScore) as NSString;
        _bestScore = NSInteger(data.floatValue);
        print("GameViewController -> best score restored: \(_bestScore)");
        GameCenterController.reportScore(self.getBestScore());
        
        self.scene.reset();
        self.scene.build();
        
        print("GameViewController -> start game center");
        GameCenterController.start();
        
        startGame();
    }
    
    func showMenu(_ msg:String, desc:String, action:String, selector:Selector!, showInstructions:Bool = false, showExitButton:Bool = true, showGameOver:Bool = false)
    {
        if(menuView != nil)
        {
            return;
        }
        
        scene.stop();
        statusView.hide();
        menuView = MenuView();
        menuView.animationStyle = AnimationStyle.scale;
        self.view.addSubview(menuView);
        menuView.setTitle(msg);
        menuView.setDescription(desc);
        
        if(showInstructions)
        {
            menuView.setInstructions(self.scene.SCORE_TO_EARN_LIFE, scoreToLevelUp: self.scene.SCORE_TO_LEVEL_UP);
        }
        else if(showGameOver)
        {
            menuView.setGameOver();
        }
        
        if(showExitButton)
        {
            menuView.setAction("exit", target: self, selector: #selector(GameViewController.exitHandler(_:)));
        }
        
        if(selector != nil)
        {
            menuView.setAction(action, target: self, selector: selector);
        }
        
        menuView.present(nil);
        
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    func getBestScore() -> NSInteger
    {
        return _bestScore;
    }
    
    func setBestScore(_ score:NSInteger)
    {
        print("GameViewController -> best score saved: \(score)");
        DataProvider.saveData(SuiteNames.SuiteBestScore, key: SuiteNames.KeyBestScore, string: "\(score)" as NSString!);
        _bestScore = score;
    }
    
    func exitHandler(_ sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        self.startGame();
    }
    
    func updateGameStatusHandler()
    {
        self.statusView.update(self.scene.currentLevel(),
            score: self.scene.currentScore(),
            nextScore: self.scene.SCORE_TO_LEVEL_UP,
            lifes:scene.currentLifes(),
            scoreNextLife:self.scene.currentScoreToNextLife());
    }
    
    func startGame()
    {
        if(menuView != nil)
        {
            menuView.removeFromSuperview();
            menuView = nil;
        }
        
        showMenu("car racing\nchallenge", desc: "", action: "PLAY", selector: #selector(GameViewController.testConnectivity(_:)), showInstructions:true, showExitButton:false);
        AudioHelper.playSound(AudioHelper.EntranceSound);
        
        self.showBanner();
    }
    
    func testConnectivity(_ sender:AnyObject!)
    {
        /* as acoes do menu agora só aparecem quando o banner é carregado (MenuView).
        if(ConnectivityHelper.isReachable() || PurchaseController.getInstance().hasPurchased())
        {
            startGameHandler(sender);
        }
        else
        {
            PurchaseController.getInstance().showDefaultPurchaseMessage({
                AlertController.getInstance().hideAlert({ self.menuView.configsHandler(); });
            });
        }
        */
        
        self.startGameHandler(sender);
    }
    
    func startGameHandler(_ sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        menuView.disableAction();
        statusView.show();
        
        func complete(_ animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            
            if(self.touchAreasImgView != nil)
            {
                self.touchAreasImgView.removeFromSuperview();
                self.touchAreasImgView = nil;
            }
            
            let newSize:CGSize = CGSize(width: self.view.width - 30, height: self.view.height);
            self.touchAreasImgView = UIImageView(image: ImageHelper.imageScaledToFit(UIImage(named: ImagesNames.TouchAreas), sizeToFit: newSize));
            self.touchAreasImgView.width -= self.touchAreasImgView.width * 0.02;
            self.touchAreasImgView.y = self.view.height - self.touchAreasImgView.height * 0.66;
            self.touchAreasImgView.alpha = 0;
            self.touchAreasImgView.center.x = self.view.center.x;
            self.view.addSubview(self.touchAreasImgView);
            
            self.scene.reset();
            self.scene.build();
            self.scene.start();
            
            self.touchAreasImgView.scale(0.5);
            UIView.animate(withDuration: AnimationTime.Default, animations: {
                self.touchAreasImgView.alpha = 1;
                self.touchAreasImgView.scale(1);
                },completion: { (animated) -> Void in
                    UIView.animate(withDuration: AnimationTime.Default, delay:AnimationTime.VerySlow + AnimationTime.Default, options:[], animations: {
                        self.touchAreasImgView.alpha = 0;
                        self.touchAreasImgView.scale(0.5);
                        }, completion:{ (animated) -> Void in
                            self.touchAreasImgView.removeFromSuperview();
                            self.touchAreasImgView = nil;
                    });
            });
        }
        
        self.menuView.dismiss(complete);
        
        AudioHelper.playSound(AudioHelper.StartGameSound);
    }
    
    func gameOverHandler()
    {
        scene.stop();
        Utils.vibrate();
        SocialController.getInstance().screenShot(self.view);
        
        if(scene.currentScore() > self.getBestScore())
        {
            self.setBestScore(scene.currentScore())
            if(!GameCenterController.isReady())
            {
                GameCenterController.authenticate({ GameCenterController.reportScore(self.getBestScore()); });
            }
            else
            {
                GameCenterController.reportScore(self.getBestScore());
            }
        }
        
        showMenu("\nGAME OVER", desc: "\nSCORE:\(scene.currentScore())\nBEST:\(self.getBestScore())\n\n", action: "TRY AGAIN", selector: #selector(GameViewController.testConnectivity(_:)), showGameOver:true);
        AudioHelper.playSound(AudioHelper.GameOverSound);
        
        self.showBanner();
    }
    
    func levelUpHandler()
    {
        print("GameViewController -> LEVEL UP");
        
        let ttl:String = "\nLEVEL \(scene.currentLevel())\n";
        //var desc:String!;
        let act:String = "GO!";
        let selector:Selector = #selector(GameViewController.resumeLevelUp(_:));
        
        scene.stop();
        showMenu(ttl, desc: "\n\ncongratulations!", action: act, selector: selector, showExitButton:false);
        scene.setTotalColumns(scene.currentColumns() - 1);
        self.showBanner();
        
        AudioHelper.playSound(AudioHelper.LevelUpSound);
    }
    
    func resumeLevelUp(_ sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        menuView.disableAction();
        statusView.show();
        
        func complete(_ animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            
            self.scene.start();
        }
        
        self.menuView.dismiss(complete);
    }
    
    //################### PRAGMA
    func applicationWillResignActive()
    {
        print("GameViewController -> app will resign active");
        
        if(!self.scene.isGamePaused())
        {
            self.scene.stop();
            self.showResumeOnStartUp = true;
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
    }
    
    func applicationDidBecomeActive()
    {
        print("GameViewController -> app did become active");
        
        if(self.showResumeOnStartUp)
        {
            self.showResumeOnStartUp = false;
            self.pauseGameHandler();
        }
        
//        AlertController.getInstance().hideAlert(nil);
    }
    
    func pauseGameHandler()
    {
        showMenu("GAME PAUSED\n\n", desc: " \n \n \nARE YOU READY?", action: "RESUME", selector: #selector(GameViewController.resumeLevelUp(_:)), showExitButton:false);
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        print("GameViewController -> GameCenter did finish");
        
        gameCenterViewController.dismiss(animated: true, completion:{
                self.applicationDidBecomeActive();
        });
    }
    
    func showBanner()
    {
        if(Configs.SAMPLE_MODE)
        {
            print("GameViewController -> show banner");
        }
    }

    override var shouldAutorotate : Bool
    {
        return false;
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait;
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool
    {
        return true;
    }
}
