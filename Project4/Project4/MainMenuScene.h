// Elijah Freestone
// MGD 1411
// Week 4
// November 18th, 2014

//
//  MainMenuScene.h
//  Project4
//
//  Created by Elijah Freestone on 11/18/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MainMenuScene : SKScene

//Declare labels which will act as a buttons
@property (strong, nonatomic) SKLabelNode *playButtonLabel;
@property (strong, nonatomic) SKLabelNode *howToPlayLabel;
@property (strong, nonatomic) SKLabelNode *aboutLabel;

@end
