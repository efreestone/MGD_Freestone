// Elijah Freestone
// MGD 1411
// Week 4
// November 15th, 2014

//
//  GameOverScene.h
//  Project3
//
//  Created by Elijah Freestone on 11/8/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameOverScene : SKScene

//Create custom init to pass in playerWin bool and change display accordingly
-(id)initWithSize:(CGSize)size didPlayerWin:(BOOL)playerWin;

//Declare play again label which will act as a button
@property (strong, nonatomic) SKLabelNode *playAgainLabel;

@end
