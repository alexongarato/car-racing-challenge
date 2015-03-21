//
//  GameViewController.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    var scene           : GameScene!;
    var menuView       : MenuView!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        self.scene = GameScene();
        scene.size = UIScreen.mainScreen().applicationFrame.size;
        scene.updateStatusHandler = self.gameStatusUpdateHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        scene.finalSceneHandler = self.finalSceneHandler;
        
        Trace.log(scene.size.description as String);
        
        let skView:SKView = self.view as! SKView;
        skView.showsFPS = Configs.DEBUG_MODE;
        skView.showsNodeCount = Configs.DEBUG_MODE;
        skView.ignoresSiblingOrder = true;
        skView.presentScene(scene);
        
        scene.build();
        
        showMenu("ARCADE CAR RACE", desc: "Infinite score. How far can you go?", action: "START", selector: Selector("startGame"));
    }
    
    func showMenu(msg:String, desc:String, action:String, selector:Selector)
    {
        menuView = MenuView();
        menuView.animationStyle = AnimationStyle.Scale;
        self.view.addSubview(menuView);
        menuView.setTitle(msg);
        menuView.setDescription(desc);
        menuView.setAction(action, target: self, selector: selector);
        menuView.present(nil);
    }
    
    func startGame()
    {
        menuView.disableAction();
        
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
    
    func gameStatusUpdateHandler()
    {
        Trace.log("SCORE:\(scene.currentScore())");
    }
    
    func gameOverHandler()
    {
        Trace.log("GAME OVER");
        scene.stop();
        showMenu("GAME OVER", desc: "SCORE: \(scene.currentScore())", action: "TRY AGAIN", selector: Selector("restartGame"));
    }
    
    func levelUpHandler()
    {
        Trace.log("LEVEL UP");
        scene.setTotalColumns(scene.currentColumns() - 1);
        scene.start();
    }
    
    func finalSceneHandler()
    {
        Trace.log("VICTORY");
        scene.stop();
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
