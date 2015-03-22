//
//  GameViewController.swift
//  Infinity Car Race
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    var scene           : GameScene!;
    var menuView        : MenuView!;
    var statusView      : GameStatusView!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        //
        self.scene = GameScene();
        scene.size = UIScreen.mainScreen().applicationFrame.size;
        scene.updateStatusHandler = self.gameStatusUpdateHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        
        Trace.log(scene.size.description as String);
        
        //
        let skView:SKView = self.view as! SKView;
        skView.showsFPS = Configs.DEBUG_MODE;
        skView.showsNodeCount = Configs.DEBUG_MODE;
        skView.ignoresSiblingOrder = true;
        skView.presentScene(scene);
        
        //
        self.statusView = GameStatusView();
        self.view.addSubview(self.statusView);
        
        //
        scene.build();
        showMenu("INFINITY CAR RACE", desc: "no score limit!\nHow far can you go?", action: "START", selector: Selector("startGame"));
    }
    
    func showMenu(msg:String, desc:String, action:String, selector:Selector)
    {
        statusView.hide();
        menuView = MenuView();
        menuView.animationStyle = AnimationStyle.Scale;
        self.view.addSubview(menuView);
        menuView.setTitle(msg);
        menuView.setDescription(desc);
        menuView.setAction(action, target: self, selector: selector);
        menuView.present(nil);
    }
    
    func gameStatusUpdateHandler()
    {
        self.statusView.update(self.scene.currentLevel(), score: self.scene.currentScore(), totalLevels: self.scene.maximunLevel());
    }
    
    func startGame()
    {
        menuView.disableAction();
        statusView.show();
        
        func complete(animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            
            scene.start();
        }
        
        self.menuView.dismiss(complete);
    }
    
    func restartGame()
    {
        menuView.disableAction();
        statusView.show();
        
        func complete(animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            
            scene.reset();
            scene.build();
            scene.start();
        }
        
        self.menuView.dismiss(complete);
    }
    
    func gameOverHandler()
    {
        scene.stop();
        showMenu("GAME OVER", desc: "SCORE: \(scene.currentScore())", action: "TRY AGAIN", selector: Selector("restartGame"));
    }
    
    func levelUpHandler()
    {
        Trace.log("LEVEL UP");
        
        if(scene.currentLevel() <= scene.maximunLevel())
        {
            scene.stop();
            var desc:String = "Less cars and more speed.\nbe careful!";
            showMenu("LEVEL \(scene.currentLevel())", desc: desc, action: "READY, SET, GO!", selector: Selector("resumeLevelUp"));
        }
        else if(scene.currentLevel() == scene.maximunLevel() + 1)
        {
            scene.stop();
            var desc:String = "the road is yours!\nIt will fit \(self.scene.currentColumns()) cars\nand your car is faster\nthen ever with infinite score and level.\n good luck!";
            showMenu("LEVEL \(scene.currentLevel())", desc: desc, action: "READY, SET, GO!", selector: Selector("resumeLevelUp"));
        }
        
        
    }
    
    func resumeLevelUp()
    {
        menuView.disableAction();
        statusView.show();
        
        func complete(animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            
            scene.setTotalColumns(scene.currentColumns() - 1);
            scene.start();
        }
        
        self.menuView.dismiss(complete);
    }
    
    //
    override func shouldAutorotate() -> Bool
    {
        return true;
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }
}
