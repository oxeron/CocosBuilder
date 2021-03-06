//
//  CCBPPhysicsNode.h
//  CocosBuilder
//
//  Created by Viktor on 10/4/13.
//
//

#import "CCNode.h"

@interface CCBPPhysicsNode : CCNode

@property (nonatomic,assign) CGPoint gravity;
@property (nonatomic,assign) float sleepTimeThreshold;
@property (nonatomic,assign) int iterations;
@property (nonatomic,assign) BOOL debugDraw;

@end
