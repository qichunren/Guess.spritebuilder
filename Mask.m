//
//  Mask.m
//  Guess
//
//  Created by qichunren on 8/5/14.
//  Copyright 2014年 Apportable. All rights reserved.
//

#import "Mask.h"


@implementation Mask

-(void)onEnter
{
    [self setUserInteractionEnabled:true];
    [super onEnter];
}


-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
//	// Touch to guess the target
//    CGPoint touchLocation = [touch locationInNode:self.parent];
//    CCLOG(@"Mask Touch location: x:%f  y:%f", touchLocation.x, touchLocation.y);
//    CCActionJumpBy * action = [CCActionJumpBy actionWithDuration:0.5 position:touchLocation height:10 jumps:1];
//    [self runAction:action];
    [self.parent touchBegan:touch withEvent:event];
    
}


@end
