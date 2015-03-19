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
    //-- main game --
    var buttonLeft              : SKSpriteNode!;
    var buttonRight             : SKSpriteNode!;
    var mainCharacter           : CustomSpriteNode!;
    var enemiesArray            : Array<CustomSpriteNode>!;
    /**
    tamanho da area dos controles baseada no tamanho da tela.
    */
    var buttonSize              : CGSize = CGSize();
    /**
    tamanho dos personagens de acordo com a quantidade de colunas.
    */
    var charactersSize          : CGSize = CGSize();
    /**
    texto com as informacoes do jogo.
    */
    var gameStatus              : SKLabelNode!;
    /**
    tamanho dos pixels quadrados.
    */
    var pixelSize               : CGFloat = 0;
    
    //-- configs --
    /**
    quantidade de pistas no jogo.
    */
    let totalColumns            : Int = 6;
    /**
    diferenca de velocidade entre os levels.
    */
    let scoresToLevelUp         : Int = 5;
    var currentLevel            : CGFloat = 1;
    var totalLifes              : Int = 10;
    var isGameOver              : Bool = false;
    
    /**
    quanto menor, maior a velocidade do jogo
    */
    var mainTrigger             : CFTimeInterval = -1;
    var mainTriggerIncrement    : CFTimeInterval = 0.01;
    
    var enemyTrigger            : CFTimeInterval = -1;
    var enemyTriggerIncrement   : CFTimeInterval = -1;
    var totalEnemiesAvoided     : Int = 0;
    var scoresToLevelUpCounter  : Int = 0;
    var enemyVerticalPath       : Array<SKAction>!;
    var enemyVelocityTime       : CFTimeInterval = 0.5;
    
    
    
    override func didMoveToView(view: SKView)
    {
        /**
        inicializar variaveis
        */
        self.enemiesArray            = Array<CustomSpriteNode>();
        self.pixelSize               = ((self.width) / (self.totalColumns.floatValue * 3));
        self.charactersSize.width    = self.pixelSize * 3;
        self.charactersSize.height   = self.pixelSize * 4;
        self.buttonSize.width        = self.width.half.roundValue;
        self.buttonSize.height       = self.buttonSize.width.half.roundValue;
        self.enemyVerticalPath       = Array<SKAction>();
        self.updateEnemyVector();
        
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
        var pixelsNode:SKSpriteNode = SKSpriteNode(texture: pixelTexture);
        self.addChild(pixelsNode);
        pixelsNode.zPosition = 1;
        pixelsNode.anchorPoint.x = 0;
        pixelsNode.anchorPoint.y = 0;

        self.backgroundColor = UIColor.clearColor();
        
        
        /**
        cria os personagens do jogo
        */
        self.mainCharacter = CustomSpriteNode();
        self.mainCharacter.color = UIColor.blackColor();
        self.mainCharacter.alpha = 0.5;
        self.mainCharacter.size = self.charactersSize;
        self.mainCharacter.x = self.mainCharacter.width.half;
        self.mainCharacter.y = self.pixelSize * 7;
        self.addChild(self.mainCharacter);
        
        
        /**
        cria os controles do jogo
        */
        self.buttonLeft = self.childNodeWithName("bt_left") as! SKSpriteNode;
        self.buttonLeft.size = self.buttonSize;
        self.buttonLeft.alpha = 0.5;
        self.buttonLeft.x = self.buttonLeft.width.half;
        self.buttonLeft.y = self.buttonLeft.height.half;
        
        self.buttonRight = self.childNodeWithName("bt_right") as! SKSpriteNode;
        self.buttonRight.size = self.buttonSize;
        self.buttonRight.alpha = 0.5;
        self.buttonRight.x = self.width - self.buttonRight.width.half;
        self.buttonRight.y = self.buttonRight.height.half;
        
        
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
        
        /** 
        start game
        */
        
        Utils.delayedCall(0.5, target: self, selector: Selector("heartBeat"), repeats: true);
        addNewEnemy();
    }
    
    func heartBeat()
    {
        NSLog("heart beat");
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        if(isGameOver)
        {
            return;
        }
        
        enemyTriggerIncrement = mainTriggerIncrement * 500;
        
        /**
        adiciona um novo inimigo na cena
        */
        if(currentTime >= enemyTrigger)
        {
            enemyTrigger = currentTime + enemyTriggerIncrement;
            addNewEnemy();
        }
        
        /**
        processa cada inimigo individualmente
        */
        for enemyBlock in enemiesArray
        {
            /**
            novo heart beat
            */
            /*if(currentTime >= mainTrigger)
            {
                //-----------
                mainTrigger = currentTime + mainTriggerIncrement;
                //-----------
                
                /**
                move o inimigo para baixo
                */
                enemyBlock.y -= pixelSize;
            }*/
            
           
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
                    totalLifes--;
                    printStatus();
                    if(totalLifes == 0)
                    {
                        isGameOver = true;
                        showGameOverMessage();
                        return;
                    }
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        /* Called when a touch begins */
        for touch: AnyObject in touches
        {
            let location = touch.locationInNode(self)
            var node:SKNode = self.nodeAtPoint(location);
            if(node.name == "bt_left")
            {
                if(mainCharacter.x > mainCharacter.width)
                {
                    mainCharacter.x -= mainCharacter.width;
                }
            }
            
            if(node.name == "bt_right")
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
        var newEnemy:CustomSpriteNode = CustomSpriteNode();
        newEnemy.size = self.charactersSize;
        self.enemiesArray.append(newEnemy);
        self.addChild(newEnemy);
        
        
        //customizacao
        newEnemy.color = UIColor.redColor();
        
        
        //configuracoes
        newEnemy.width -= 0.1;
        newEnemy.x = self.charactersSize.width.half + (self.charactersSize.width * Utils.random(self.totalColumns-1).floatValue);
        newEnemy.y = self.height// + newEnemy.height.half;
        newEnemy.zPosition = 10;
        
        func completion()
        {
            if(!newEnemy.isTouched)
            {
                totalEnemiesAvoided++;
                self.scoresToLevelUpCounter++;
                if(self.scoresToLevelUpCounter > self.scoresToLevelUp)
                {
                    self.scoresToLevelUpCounter = 0;
                    self.currentLevel++;
                }
            }
            
            self.removeChildrenInArray([newEnemy]);
            enemiesArray.removeAtIndex(0);
            self.printStatus();
        }
        var act:SKAction = SKAction.sequence(self.enemyVerticalPath);
        newEnemy.runAction(act, completion: completion);
        
        NSLog("new enemy");
    }
    
    func updateEnemyVector()
    {
        func timing(value:Float) -> Float
        {
            return value < 1 ? 0 : value;
        }
        var act:SKAction!;
        var total:Int = Int(self.height / self.pixelSize);
        for(var i:Int = 0; i <  total; i++)
        {
            act = SKAction.moveToY(self.pixelSize * CGFloat(total - i), duration: self.enemyVelocityTime);
            act.timingFunction = timing;
            self.enemyVerticalPath.append(act);
        }
    }
    
    func printStatus()
    {
        self.gameStatus.text = "level:\(Int(self.currentLevel))  |  life:\(self.totalLifes)  |  score:\(self.totalEnemiesAvoided)";
        NSLog(self.gameStatus.text);
        self.gameStatus.zPosition = 10000;
    }
    
    func showGameOverMessage()
    {
        NSLog("GAME OVER");
        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster");
        myLabel.text = "GAME OVER";
        myLabel.fontSize = 35;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
        myLabel.zPosition = 10000;
    }
}

class CustomSpriteNode:SKSpriteNode
{
    var isTouched:Bool = false;
}


