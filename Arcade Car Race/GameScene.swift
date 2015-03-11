//
//  GameScene.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    var buttonLeft          : SKSpriteNode!;
    var buttonRight         : SKSpriteNode!;
    var mainCharacter       : SKSpriteNode!;
    var enemiesArray        : Array<SKSpriteNode>!;
    var slideVelocity       : CGFloat = 0;
    var enemyVelocity       : CGFloat = 1;
    let maxEnemies          : Int = 3;
    var btSize              : CGFloat = 0;
    let columns             : Int = 2;
    
    override func didMoveToView(view: SKView)
    {
        enemiesArray = Array<SKSpriteNode>();
        btSize = self.size.width * 0.5;
        
        //set main controll buttons
        buttonLeft = self.childNodeWithName("bt_left") as SKSpriteNode;
        buttonRight = self.childNodeWithName("bt_right") as SKSpriteNode;
        
        buttonLeft.size.width = btSize;
        buttonLeft.size.height = btSize;
        
        buttonRight.size.width = btSize;
        buttonRight.size.height = btSize;
        
        buttonLeft.position.x = buttonLeft.size.width.half;
        buttonLeft.position.y = buttonLeft.size.width.half;
        
        buttonRight.position.x = self.size.width - buttonRight.size.width.half;
        buttonRight.position.y = buttonRight.size.height.half;
        
        //set main character
        mainCharacter = SKSpriteNode(imageNamed:"Spaceship");
        mainCharacter.setScale(0.27);
        mainCharacter.position.x = self.size.width.half;
        mainCharacter.position.y = btSize + mainCharacter.size.width.half;
        self.addChild(mainCharacter);
        
        //set variables
        slideVelocity = (self.size.width - mainCharacter.size.width) / CGFloat(columns);
        
        addNewEnemy();
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        /* Called when a touch begins */
        for touch: AnyObject in touches
        {
            let location = touch.locationInNode(self)
            var node:SKNode = self.nodeAtPoint(location);
            if(node.name == "bt_left")
            {
                NSLog("touch left button");
                if(mainCharacter.position.x > mainCharacter.size.width.half)
                {
                    mainCharacter.position.x -= slideVelocity;
                    if(mainCharacter.position.x < mainCharacter.size.width.half)
                    {
                        mainCharacter.position.x = mainCharacter.size.width.half;
                    }
                }
            }
            
            if(node.name == "bt_right")
            {
                NSLog("touch right button");
                
                if(mainCharacter.position.x < self.size.width - mainCharacter.size.width.half)
                {
                    mainCharacter.position.x += slideVelocity;
                    if(mainCharacter.position.x > self.size.width - mainCharacter.size.width.half)
                    {
                        mainCharacter.position.x = self.size.width - mainCharacter.size.width.half;
                    }
                }
            }
            
            /*
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)*/
            
        }
    }
    
    /*
    func showPrepareMessage()
    {
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Ready";
        myLabel.fontSize = 50;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }
    */
    var triggerCounter:CGFloat = 0;
    var trigger:CGFloat = 0;
    override func update(currentTime: CFTimeInterval)
    {
        triggerCounter += enemyVelocity;
        for enemyBlock in enemiesArray
        {
            enemyBlock.position.y -= enemyVelocity;
            
            if(enemyBlock.position.y + enemyBlock.size.height.half < 0)//end on enemy life
            {
                enemyBlock.position.y = self.size.height + enemyBlock.size.height.half;
                enemyBlock.removeFromParent();
                enemiesArray.removeAtIndex(0);
                
                enemyVelocity+=0.05;//increase velocity
                
//                NSLog("one enemy removed");
            }
            
            var triggerRoof:CGFloat = (enemyBlock.size.height * 4) + (enemyVelocity * enemyVelocity).half;
            if(triggerCounter > triggerRoof)
            {
                NSLog("triggerRoof:\(triggerRoof)");
                NSLog("velocity:\(enemyVelocity)");
                
                triggerCounter = 0;
                addNewEnemy();
            }
        }
    }
    
    func addNewEnemy()
    {
        if(enemiesArray.count >= maxEnemies)
        {
            return;
        }
        
        var newSize:CGFloat = self.size.width / 3;
        var newEnemy:SKSpriteNode = SKSpriteNode();
        newEnemy.size.width = newSize;
        newEnemy.size.height = newSize;
        newEnemy.color = UIColor.redColor();
        newEnemy.position.x = newSize.half + (slideVelocity * CGFloat(random(columns)));
        newEnemy.position.y = self.size.height + newEnemy.size.height.half;
        enemiesArray.append(newEnemy);
        self.addChild(newEnemy);
        newEnemy.zPosition = -1;
        
//        NSLog("new enemy added at x:\(newEnemy.position.x)");
    }
    
    func random(i:Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(1+i)));
    }
}
