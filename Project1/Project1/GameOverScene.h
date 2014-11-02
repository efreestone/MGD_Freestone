// Elijah Freestone
// MGD 1411
// Week 1
// November 1st, 2014

//
//  GameOverScene.h
//  Project1
//
//  Created by Elijah Freestone on 11/1/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameOverScene : SKScene

//Create custom init to pass in playerWin bool and change display accordingly
-(id)initWithSize:(CGSize)size didPlayerWin:(BOOL)playerWin;

@end
