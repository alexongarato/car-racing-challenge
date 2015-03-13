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
    var buttonLeft              : SKSpriteNode!;
    var buttonRight             : SKSpriteNode!;
    var mainCharacter           : CustomSpriteNode!;
    var enemiesArray            : Array<CustomSpriteNode>!;
    var currentEnemyVelocity    : CGFloat = 20;
    var currentLevel            : CGFloat = 1;
    var buttonSize              : CGSize = CGSize();
    var charactersSize          : CGSize = CGSize();
    var levelTriggerCounter     : Int = 1;
    var enemyTriggerCounter     : Int = 0;
    var distBetweenEnemies      : Int = 0;
    var totalLifes              : Int = 10;
    var isGameOver              : Bool = false;
    
    /**/
    let distBetweenLevels       : Int = 700;
    let totalColumns            : Int = 6;
    let velocityIncrement       : CGFloat = 1;
    
    
    override func didMoveToView(view: SKView)
    {
        enemiesArray = Array<CustomSpriteNode>();
        
        charactersSize.width = self.size.width / CGFloat(totalColumns);
        charactersSize.height = charactersSize.width * 1.5;
        
        buttonSize.width = self.size.width.half;
        buttonSize.height = buttonSize.width.half;
        
        //set main controll buttons
        buttonLeft = self.childNodeWithName("bt_left") as SKSpriteNode;
        buttonRight = self.childNodeWithName("bt_right") as SKSpriteNode;
        
        buttonLeft.size = buttonSize;
        buttonRight.size = buttonSize;
        
        buttonLeft.alpha = 0.5;
        buttonRight.alpha = 0.5;
        
        buttonLeft.position.x = buttonLeft.size.width.half;
        buttonLeft.position.y = buttonLeft.size.height.half;
        
        buttonRight.position.x = self.size.width - buttonRight.size.width.half;
        buttonRight.position.y = buttonRight.size.height.half;
        
        //set main character
        mainCharacter = CustomSpriteNode();
        mainCharacter.color = UIColor.blackColor();
        mainCharacter.alpha = 0.5;
        mainCharacter.size = charactersSize;
        mainCharacter.position.x = mainCharacter.size.width.half;
        mainCharacter.position.y = buttonSize.height + charactersSize.height.half;
//        mainCharacter.showHitArea();
        
        self.addChild(mainCharacter);
        
        addNewEnemy();
        
        printStatus();
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
                if(mainCharacter.position.x > mainCharacter.size.width.half)
                {
                    mainCharacter.position.x -= mainCharacter.size.width;
                }
            }
            
            if(node.name == "bt_right")
            {
                if(mainCharacter.position.x < self.size.width - mainCharacter.size.width.half)
                {
                    mainCharacter.position.x += mainCharacter.size.width;
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
    
    
    func showGameOverMessage()
    {
        let myLabel = SKLabelNode(fontNamed:"Chalkduster");
        myLabel.text = "GAME OVER";
        myLabel.fontSize = 35;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        if(isGameOver)
        {
            return;
        }
        
        levelTriggerCounter++;
        enemyTriggerCounter++;
        
        distBetweenEnemies = Int(charactersSize.height * 3) / Int(currentLevel);
        
        if(enemyTriggerCounter > distBetweenEnemies)
        {
            enemyTriggerCounter = 0;
            addNewEnemy();
        }
        
        for enemyBlock in enemiesArray
        {
            if(enemyBlock.hits(mainCharacter))
            {
                if(!enemyBlock.isTouched)
                {
                    enemyBlock.isTouched = true;
                    enemyBlock.color = UIColor.blueColor();
                    totalLifes--;
                    printStatus();
                    if(totalLifes == 0)
                    {
                        isGameOver = true;
                        showGameOverMessage();
                    }
                    
                }
            }
            
            enemyBlock.position.y -= currentEnemyVelocity;
            
            if(enemyBlock.position.y + enemyBlock.size.height.half < 0)//end on enemy life
            {
                enemyBlock.position.y = self.size.height + enemyBlock.size.height.half;
                enemyBlock.removeFromParent();
                enemiesArray.removeAtIndex(0);
            }
            
            if(levelTriggerCounter > distBetweenLevels)
            {
                currentLevel++;
                currentEnemyVelocity += velocityIncrement;
                levelTriggerCounter = 0;
                //                addNewEnemy()//add bonus enemy
                printStatus();
            }
        }
    }
    
    func addNewEnemy()
    {
        var newEnemy:CustomSpriteNode = CustomSpriteNode();
        newEnemy.size = charactersSize;
        newEnemy.color = UIColor.redColor();
        newEnemy.position.x = newEnemy.size.width.half + (charactersSize.width * CGFloat(random(totalColumns-1)));
        newEnemy.position.y = self.size.height + newEnemy.size.height.half;
        enemiesArray.append(newEnemy);
        self.addChild(newEnemy);
        newEnemy.zPosition = -1;
    }
    
    func random(i:Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(1+i)));
    }
    
    func printStatus()
    {
        NSLog("level:\(currentLevel) - life:\(totalLifes) - velocity:\(currentEnemyVelocity)");
    }
}

class CustomSpriteNode:SKSpriteNode
{
    //constants
    let hitRadius           : CGFloat = 1;
    
    //properties
    var isTouched           : Bool = false;
    var right               : CGFloat { get { return (self.position.x + (self.size.width.half * self.hitRadius));} };
    var left                : CGFloat { get { return (self.position.x - (self.size.width.half * self.hitRadius));} };
    var top                 : CGFloat { get { return (self.position.y + (self.size.height.half * self.hitRadius));} };
    var bottom              : CGFloat { get { return (self.position.y - (self.size.height.half * self.hitRadius));} };
    
    func hits(sprite:CustomSpriteNode) -> Bool
    {
        if(self.right > sprite.left && self.left < sprite.right)
        {
            if(self.top > sprite.bottom && self.bottom < sprite.top)
            {
                return true;
            }
        }
        return false;
    }
    
    func showHitArea()
    {
        var hit:CustomSpriteNode = CustomSpriteNode();
        self.addChild(hit);
        hit.color = UIColor.yellowColor();
        hit.size.width = (right - self.position.x) * 2;
        hit.size.height = (top - self.position.y) * 2;
    }
}
