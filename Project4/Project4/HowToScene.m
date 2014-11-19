//
//  HowToScene.m
//  Project4
//
//  Created by Elijah Freestone on 11/18/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "HowToScene.h"
#import "MainMenuScene.h"

@implementation HowToScene {
    SKColor *iOSBlueButtonColor;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Set background
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        //Set color similar to the blue of default iOS button
        iOSBlueButtonColor = [SKColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        
        //Adjust font size based on device
        CGFloat fontSize = 40;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 75;
        }
        
        //Create and set message label
        self.backLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.backLabel.text = @"Back";
        self.backLabel.name = @"backLabel";
        self.backLabel.fontColor = iOSBlueButtonColor;
        self.backLabel.fontSize = fontSize * 0.5;
        float backLabelPlacement = self.backLabel.frame.size.height + fontSize * 0.5;
        self.backLabel.position = CGPointMake(backLabelPlacement, self.size.height - (fontSize * 0.6));
        [self addChild:self.backLabel];
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
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    if ([touchedLabel.name isEqual: @"backLabel"]) {
        self.backLabel.fontColor = iOSBlueButtonColor;
        SKScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.size];
        SKTransition *reveal = [SKTransition doorsOpenHorizontalWithDuration:0.5];
        [self.view presentScene:mainMenuScene transition: reveal];
    }
}

@end
