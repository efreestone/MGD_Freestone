// Elijah Freestone
// MGD 1411
// Week 4
// November 18th, 2014

//
//  HowToScene.m
//  Project4
//
//  Created by Elijah Freestone on 11/18/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "HowToScene.h"
#import "MainMenuScene.h"
#import "GameScene.h"

@implementation HowToScene {
    SKColor *iOSBlueButtonColor;
    NSString *backgroundName;
    int backgroundNumber;
    CGFloat backgroundPadding;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Adjust font size based on device
        CGFloat fontSize = 40;
        backgroundPadding = 0;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 75;
            backgroundPadding = 110;
        }
        
        //Set background to first of three images.
        //background number is incremented to display the next image
        backgroundNumber = 1;
        backgroundName = [NSString stringWithFormat:@"how-to-%d", backgroundNumber];
        
        //Set background
        self.backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:backgroundName];
        self.backgroundImage.size = CGSizeMake(self.size.width - backgroundPadding, self.size.height - backgroundPadding);
        self.backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:self.backgroundImage];
        
        //Set color similar to the blue of default iOS button
        iOSBlueButtonColor = [SKColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        
        //Create and set back label
        self.backLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.backLabel.text = @"Menu";
        self.backLabel.name = @"backLabel";
        self.backLabel.zPosition = 2;
        self.backLabel.fontColor = iOSBlueButtonColor;
        self.backLabel.fontSize = fontSize * 0.5;
        float backLabelPlacement = self.backLabel.frame.size.height + fontSize * 0.5;
        self.backLabel.position = CGPointMake(backLabelPlacement, self.size.height - (fontSize * 0.6));
        [self addChild:self.backLabel];
        
        //Creat and set next label
        self.nextLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.nextLabel.text = @"Next";
        self.nextLabel.name = @"nextLabel";
        self.nextLabel.zPosition = 2;
        self.nextLabel.fontColor = iOSBlueButtonColor;
        self.nextLabel.fontSize = fontSize * 0.5;
        float nextLabelWidth = self.nextLabel.frame.size.width;
        self.nextLabel.position = CGPointMake(self.size.width - nextLabelWidth, self.size.height - (fontSize * 0.6));
        [self addChild:self.nextLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        self.backLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    if ([touchedLabel.name isEqual: @"nextLabel"]) {
        self.nextLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    if ([touchedLabel.name isEqual:@"playLabel"]) {
        self.nextLabel.fontColor = [SKColor grayColor];
        return;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        self.backLabel.fontColor = iOSBlueButtonColor;
        SKScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.size];
        SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
        [self.view presentScene:mainMenuScene transition: reveal];
    }
    
    //Next label cycles through backgrounds
    if ([touchedLabel.name isEqual: @"nextLabel"]) {
        self.nextLabel.fontColor = iOSBlueButtonColor;
        backgroundNumber++;
        backgroundName = [NSString stringWithFormat:@"how-to-%d", backgroundNumber];
        if (backgroundNumber <= 3) {
            NSLog(@"Number = %d", backgroundNumber);
            [self.backgroundImage removeFromParent];
            self.backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:backgroundName];
            self.backgroundImage.size = CGSizeMake(self.size.width - backgroundPadding, self.size.height - backgroundPadding);
            self.backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
            [self addChild:self.backgroundImage];
            //Change next to play once all three tut images have been displayed
            if (backgroundNumber == 3) {
                self.nextLabel.name = @"playLabel";
                self.nextLabel.text = @"Play";
                touchedLabel = nil;
            }
        }
    }
    
    //Play label starts the game and only exists once all 3 tut images have been shown
    if ([touchedLabel.name isEqual:@"playLabel"]) {
        SKScene *gameScene = [[GameScene alloc] initWithSize:self.size];
        self.nextLabel.fontColor = iOSBlueButtonColor;
        //Create actions to wait and go to appropriate scene
        SKAction *waitDuration = [SKAction waitForDuration:0.05];
        SKAction *revealGameScene = [SKAction runBlock:^{
            SKTransition *reveal = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:gameScene transition:reveal];
        }];
        [self runAction:[SKAction sequence:@[waitDuration, revealGameScene]]];
        
    }
    
    
}

@end
