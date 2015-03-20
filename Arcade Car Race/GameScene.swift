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
    //-- pointers --
    var buttonLeft              : SKSpriteNode!;
    var buttonRight             : SKSpriteNode!;
    var mainCharacter           : CustomSpriteNode!;
    var enemiesArray            : Array<CustomSpriteNode>!;
    var buttonSize              : CGSize = CGSize();
    var charactersSize          : CGSize = CGSize();
    var gameStatus              : SKLabelNode!;
    var pixelSize               : CGFloat = 0;
    var pixelsNode              : SKSpriteNode!;
    
    //-- configs --
    let totalColumns            : Int = 6;
    var levelCounter            : Int = 1;
    var lifesCounter            : Int = 1;
    var isGameOver              : Bool = false;
    var enemiesAvoidedCounter   : Int = 0;
    var levelUpCounter          : Int = 0;
    let totalAvoidedToLevelUp   : Int = 1;
    let IDBtLeft                : String = "bt_left";
    let IDBtRight               : String = "bt_right";
    
    /**
    quanto menor, maior a velocidade do jogo
    */
    let intervalBetweenLevels   : CFTimeInterval = 0.01;
    var loopsTimeCounter        : CFTimeInterval = -1;
    var intervalBetweenLoops    : CFTimeInterval = 0.5;
    
    var newEnemyTotal           : Int = 12;
    var newEnemyCounter         : Int = 0;
    
    
    override func didMoveToView(view: SKView)
    {
        self.build();
    }
    
    func build()
    {
        self.removeAllChildren();
        
        /**
        inicializar variaveis
        */
        self.enemiesArray            = Array<CustomSpriteNode>();
        self.pixelSize               = CGFloat(self.width.intValue / (self.totalColumns * 3));
        self.charactersSize.width    = self.pixelSize * 3;
        self.charactersSize.height   = self.pixelSize * 4;
        self.buttonSize.width        = self.width.half.roundValue;
        self.buttonSize.height       = self.buttonSize.width.half.roundValue;
        
        NSLog("pixelSize:\(self.pixelSize)");
        
        /**
        criar malha de pixels de acordo com a quantidade de pistas.
        */
        var pixelFrame:CGRect = CGRect(x: -2, y: 0, width: self.pixelSize, height: self.pixelSize);
        var pixelCGImage:CGImageRef = UIImage(named:"PixelOff")!.CGImage;
        
        UIGraphicsBeginImageContext(self.size);
        var context:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, self.frame, UIImage(named:"Background")!.CGImage);
        CGContextDrawTiledImage(context, pixelFrame, pixelCGImage);
        var tiledPixels:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        var pixelTexture:SKTexture = SKTexture(CGImage: tiledPixels.CGImage);
        
        pixelsNode = SKSpriteNode(texture: pixelTexture);
        self.addChild(pixelsNode);
        pixelsNode.zPosition = 1;
        pixelsNode.anchorPoint.x = 0;
        pixelsNode.anchorPoint.y = -1;
        pixelsNode.x = 2;
        pixelsNode.y = -self.size.height;
        
        /**
        cria os personagens do jogo
        */
        self.mainCharacter = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize));
        self.mainCharacter.size = self.charactersSize;
        self.mainCharacter.x = self.mainCharacter.width.half;
        var totalPixelsV:CGFloat = self.size.height / self.pixelSize;
        var vPixelsAlign:CGFloat = (self.pixelSize * (totalPixelsV - totalPixelsV.roundValue)) - 1;//encontra o alinhamento vertical do mainchar com a malha de pixels.
        self.mainCharacter.y = (self.pixelSize * 2) + vPixelsAlign;
        self.addChild(self.mainCharacter);
        
        NSLog("total pixels v:\(Int(self.size.height / self.pixelSize))");
        
        /**
        cria os controles do jogo
        */
        self.buttonLeft = SKSpriteNode();
        self.buttonLeft.size = self.buttonSize;
        self.buttonLeft.color = UIColor.yellowColor();
        self.buttonLeft.alpha = 0.5;
        self.buttonLeft.x = self.buttonLeft.width.half;
        self.buttonLeft.y = self.buttonLeft.height.half;
        self.buttonLeft.name = self.IDBtLeft;
        self.addChild(self.buttonLeft);
        
        self.buttonRight = SKSpriteNode();
        self.buttonRight.size = self.buttonSize;
        self.buttonRight.color = UIColor.redColor();
        self.buttonRight.alpha = 0.5;
        self.buttonRight.x = self.width - self.buttonRight.width.half;
        self.buttonRight.y = self.buttonRight.height.half;
        self.buttonRight.name = self.IDBtRight;
        self.addChild(self.buttonRight);
        
        /**
        configurar posicao z da interface
        */
        self.mainCharacter.zPosition = 20;
        self.buttonLeft.zPosition = 21;
        self.buttonRight.zPosition = 22;
        
        /**
        configurar painel do jogo
        */
        self.gameStatus = SKLabelNode();
        self.gameStatus.x = self.width.half;
        self.gameStatus.y = self.height - 25;
        self.gameStatus.fontSize = 25;
        self.gameStatus.text = "initializing...";
        self.addChild(self.gameStatus);
        self.printStatus();
        
        //
        addNewEnemy();
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        if(isGameOver)
        {
            return;
        }
        
        /**
        processa cada inimigo individualmente
        */
        if(currentTime >= loopsTimeCounter)
        {
            /**
            novo heart beat
            */
            
            //-----------
            loopsTimeCounter = currentTime + intervalBetweenLoops;
            //-----------
            
            self.newEnemyCounter++;
            if(self.newEnemyCounter >= self.newEnemyTotal)
            {
                self.newEnemyCounter = 0;
                addNewEnemy();
            }
            
            for enemyBlock in enemiesArray
            {
                /**
                move o inimigo para baixo
                */
                enemyBlock.y -= pixelSize;
                
                /**
                quando o inimigo sai da tela. end of life.
                */
                if(enemyBlock.y + enemyBlock.height.half < 0)
                {
                    if(!enemyBlock.isTouched)
                    {
                        enemiesAvoidedCounter++;
                        self.levelUpCounter++;
                        if(self.levelUpCounter > self.totalAvoidedToLevelUp)
                        {
                            self.levelUpCounter = 0;
                            self.levelCounter++;
                        }
                    }
                    
                    self.removeChildrenInArray([enemyBlock]);
                    enemiesArray.removeAtIndex(0);
                    self.printStatus();
                }
            }
        }
        
        for enemyBlock in enemiesArray
        {
            if(enemyBlock.intersectsNode(mainCharacter))
            {
                if(!enemyBlock.isTouched)
                {
                    enemyBlock.isTouched = true;
                    
                    /**
                    customizar inimigo quando atingido
                    */
                    enemyBlock.color = UIColor.blueColor();
                    
                    
                    /**
                    atualizacao das variaveis do jogo
                    */
                    lifesCounter--;
                    printStatus();
                    if(lifesCounter == 0)
                    {
                        isGameOver = true;
                        showGameOverMessage();
                        return;
                    }
                }
            }
        }
        
        if(self.intervalBetweenLoops > 0.03)
        {
//            self.intervalBetweenLoops -= 0.003;
        }
    }
    
    override func touchesBegan(touches: (NSSet!), withEvent event: UIEvent)
    {
        if(isGameOver)
        {
            return;
        }
        
        /* Called when a touch begins */
        for touch: AnyObject in touches
        {
            let location = touch.locationInNode(self)
            var node:SKNode = self.nodeAtPoint(location);
            if(node.name == self.IDBtLeft)
            {
                if(mainCharacter.x > mainCharacter.width)
                {
                    mainCharacter.x -= mainCharacter.width;
                }
            }
            
            if(node.name == self.IDBtRight)
            {
                if(mainCharacter.x < self.width - mainCharacter.width)
                {
                    mainCharacter.x += mainCharacter.width;
                }
            }
        }
    }
    
    func addNewEnemy()
    {
        var newEnemy:CustomSpriteNode = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize), size: self.charactersSize);
        newEnemy.size = self.charactersSize;
        self.enemiesArray.append(newEnemy);
        self.addChild(newEnemy);
        
        //configuracoes
        newEnemy.width -= 0.1;
        newEnemy.x = self.charactersSize.width.half + (self.charactersSize.width * Utils.random(self.totalColumns-1).floatValue);
        newEnemy.y = self.height// + newEnemy.height.half;
        newEnemy.zPosition = 10;
    }
    
    func printStatus()
    {
        self.gameStatus.text = "level:\(Int(self.levelCounter))  |  life:\(self.lifesCounter)  |  score:\(self.enemiesAvoidedCounter)";
        self.gameStatus.zPosition = 1000;
        NSLog(self.gameStatus.text);
    }
    
    func showGameOverMessage()
    {
        NSLog("GAME OVER");
        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster");
        myLabel.text = "GAME OVER";
        myLabel.fontSize = 35;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel);
        myLabel.zPosition = 1000;
    }
}

class Pixel
{
    var active:Bool = false;
    var x:CGFloat = 0;
    var y:CGFloat = 0;
    
    init(x:CGFloat, y:CGFloat, active:Bool)
    {
        self.x = x;
        self.y = y;
        self.active = active;
    }
}

class CustomSpriteNode:SKSpriteNode
{
    var isTouched:Bool = false;
}


