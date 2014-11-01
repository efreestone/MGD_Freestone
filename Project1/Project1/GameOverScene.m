//
//  GameOverScene.m
//  Project1
//
//  Created by Elijah Freestone on 11/1/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size didPlayerWin:(BOOL)playerWin {
    if (self = [super initWithSize:size]) {
        //Set background image. It looks like SpriteKit automatically uses the correct asset for the device type.
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        //Set message based on if player won
        NSString *messageString = @"Sorry, you lost.";
        if (playerWin) {
            messageString = @"Congratulations, you won!";
        }
        
        CGFloat fontSize = 40;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 95;
        }
        
        //Create and set message label
        SKLabelNode *messageLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        messageLabel.text = messageString;
        messageLabel.fontColor = [SKColor whiteColor];
        messageLabel.fontSize = fontSize;
        messageLabel.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:messageLabel];
        
        //Create actions to wait 2 seconds and go back to Game Scene
        SKAction *waitDuration = [SKAction waitForDuration:2.0];
        SKAction *revealGameScene = [SKAction runBlock:^{
            SKTransition *reveal = [SKTransition doorsCloseVerticalWithDuration:0.5];
            SKScene * myScene = [[GameScene alloc] initWithSize:self.size];
            [self.view presentScene:myScene transition: reveal];
        }];

        [self runAction:[SKAction sequence:@[waitDuration, revealGameScene]]];
    }
    return self;

}

@end
