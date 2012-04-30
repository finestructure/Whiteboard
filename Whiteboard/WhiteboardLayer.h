//
//  WhiteboardLayer.h
//  CocosTest
//
//  Created by Sven A. Schmidt on 30.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "CCLayer.h"

@class CCRenderTexture;
@class CCScene;

@interface WhiteboardLayer : CCLayer

@property (nonatomic) float penWidth;
@property (nonatomic) float overdraw;
@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic, retain) NSMutableArray *velocities;
@property (nonatomic, retain) NSMutableArray *circlesPoints;
@property (nonatomic) BOOL connectingLine;
@property (nonatomic) BOOL finishingLine;
@property (nonatomic) CGPoint prevC;
@property (nonatomic) CGPoint prevD;
@property (nonatomic) CGPoint prevG;
@property (nonatomic) CGPoint prevI;
@property (nonatomic, strong) CCRenderTexture *renderTexture;

+ (CCScene *) scene;

- (void)startNewLineFrom:(CGPoint)newPoint withSize:(CGFloat)aSize;
- (void)endLineAt:(CGPoint)aEndPoint withSize:(CGFloat)aSize;
- (void)addPoint:(CGPoint)newPoint withSize:(CGFloat)size;

@end
