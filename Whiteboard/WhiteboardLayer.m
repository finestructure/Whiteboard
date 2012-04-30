//
//  WhiteboardLayer.m
//  CocosTest
//
//  Created by Sven A. Schmidt on 30.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "WhiteboardLayer.h"

#import "cocos2d.h"

#import "CCRenderTextureWithDepth.h"
#import "Database.h"
#import "Globals.h"
#import "LinePoint.h"
#import "WBEvent.h"


typedef struct _LineVertex {
CGPoint pos;
float z;
ccColor4F color;
} LineVertex;


@implementation WhiteboardLayer

@synthesize penWidth = _penWidth;
@synthesize overdraw = _overdraw;
@synthesize points = _points;
@synthesize velocities = _velocities;
@synthesize circlesPoints = _circlesPoints;
@synthesize connectingLine = _connectingLine;
@synthesize finishingLine = _finishingLine;
@synthesize prevC = _prevC;
@synthesize prevD = _prevD;
@synthesize prevG = _prevG;
@synthesize prevI = _prevI;
@synthesize renderTexture = _renderTexture;


+ (CCScene *)scene
{
  CCScene *scene = [CCScene node];
  WhiteboardLayer *layer = [WhiteboardLayer node];
  [scene addChild:layer];
  return scene;
}


- (id)init 
{
  self = [super init];
  if (self) {
    _penWidth = 2;
    _overdraw = 1;
    _points = [NSMutableArray array];
    _velocities = [NSMutableArray array];
    _circlesPoints = [NSMutableArray array];

    shaderProgram_ = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];

    _renderTexture = [[CCRenderTextureWithDepth alloc] initWithWidth:(int)self.contentSize.width height:(int)self.contentSize.height andDepthFormat:GL_DEPTH_COMPONENT24_OES];
    _renderTexture.anchorPoint = ccp(0, 0);
    _renderTexture.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [_renderTexture clear:1.0f g:1.0f b:1.0f a:0];
    [self addChild:_renderTexture];

    self.isTouchEnabled = YES;
  }
  return self;
}


#pragma mark - Drawing


#define ADD_TRIANGLE(A, B, C, Z) vertices[index].pos = A, vertices[index++].z = Z, vertices[index].pos = B, vertices[index++].z = Z, vertices[index].pos = C, vertices[index++].z = Z

- (void)drawLines:(NSArray *)linePoints withColor:(ccColor4F)color
{
  unsigned int numberOfVertices = ([linePoints count] - 1) * 18;
  LineVertex *vertices = calloc(sizeof(LineVertex), numberOfVertices);
  
  CGPoint prevPoint = [(LinePoint *)[linePoints objectAtIndex:0] pos];
  float prevValue = [(LinePoint *)[linePoints objectAtIndex:0] width];
  float curValue;
  int index = 0;
  for (int i = 1; i < [linePoints count]; ++i) {
    LinePoint *pointValue = [linePoints objectAtIndex:i];
    CGPoint curPoint = [pointValue pos];
    curValue = [pointValue width];
    
    //! equal points, skip them
    if (ccpFuzzyEqual(curPoint, prevPoint, 0.0001f)) {
      continue;
    }
    
    CGPoint dir = ccpSub(curPoint, prevPoint);
    CGPoint perpendicular = ccpNormalize(ccpPerp(dir));
    CGPoint A = ccpAdd(prevPoint, ccpMult(perpendicular, prevValue / 2));
    CGPoint B = ccpSub(prevPoint, ccpMult(perpendicular, prevValue / 2));
    CGPoint C = ccpAdd(curPoint, ccpMult(perpendicular, curValue / 2));
    CGPoint D = ccpSub(curPoint, ccpMult(perpendicular, curValue / 2));
    
    //! continuing line
    if (_connectingLine) {
      A = _prevC;
      B = _prevD;
    } else if (index == 0) {
      //! circle at start of line, revert direction
      [_circlesPoints addObject:pointValue];
      [_circlesPoints addObject:[linePoints objectAtIndex:i - 1]];
    }
    
    ADD_TRIANGLE(A, B, C, 1.0f);
    ADD_TRIANGLE(B, C, D, 1.0f);
    
    _prevD = D;
    _prevC = C;
    if (_finishingLine && (i == [linePoints count] - 1)) {
      [_circlesPoints addObject:[linePoints objectAtIndex:i - 1]];
      [_circlesPoints addObject:pointValue];
      _finishingLine = NO;
    }
    prevPoint = curPoint;
    prevValue = curValue;
    
    //! Add overdraw
    CGPoint F = ccpAdd(A, ccpMult(perpendicular, _overdraw));
    CGPoint G = ccpAdd(C, ccpMult(perpendicular, _overdraw));
    CGPoint H = ccpSub(B, ccpMult(perpendicular, _overdraw));
    CGPoint I = ccpSub(D, ccpMult(perpendicular, _overdraw));
    
    //! end vertices of last line are the start of this one, also for the overdraw
    if (_connectingLine) {
      F = _prevG;
      H = _prevI;
    }
    
    _prevG = G;
    _prevI = I;
    
    ADD_TRIANGLE(F, A, G, 2.0f);
    ADD_TRIANGLE(A, G, C, 2.0f);
    ADD_TRIANGLE(B, H, D, 2.0f);
    ADD_TRIANGLE(H, D, I, 2.0f);
  }
  [self fillLineTriangles:vertices count:index withColor:color];
  
  if (index > 0) {
    _connectingLine = YES;
  }
  
  free(vertices);
}


- (void)fillLineTriangles:(LineVertex *)vertices count:(NSUInteger)count withColor:(ccColor4F)color
{
  [shaderProgram_ use];
  [shaderProgram_ setUniformForModelViewProjectionMatrix];
  
  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
  
  ccColor4F fullColor = color;
  ccColor4F fadeOutColor = color;
  fadeOutColor.a = 0;
  
  for (int i = 0; i < count / 18; ++i) {
    for (int j = 0; j < 6; ++j) {
      vertices[i * 18 + j].color = color;
    }
    
    //! FAG
    vertices[i * 18 + 6].color = fadeOutColor;
    vertices[i * 18 + 7].color = fullColor;
    vertices[i * 18 + 8].color = fadeOutColor;
    
    //! AGD
    vertices[i * 18 + 9].color = fullColor;
    vertices[i * 18 + 10].color = fadeOutColor;
    vertices[i * 18 + 11].color = fullColor;
    
    //! BHC
    vertices[i * 18 + 12].color = fullColor;
    vertices[i * 18 + 13].color = fadeOutColor;
    vertices[i * 18 + 14].color = fullColor;
    
    //! HCI
    vertices[i * 18 + 15].color = fadeOutColor;
    vertices[i * 18 + 16].color = fullColor;
    vertices[i * 18 + 17].color = fadeOutColor;
  }
  
  glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].pos);
  glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].color);
  
  
  glDepthFunc(GL_LEQUAL);
  glEnable(GL_DEPTH_TEST);
  glDrawArrays(GL_TRIANGLES, 0, (GLsizei)count);
  
  for (unsigned int i = 0; i < [_circlesPoints count] / 2; ++i) {
    LinePoint *prevPoint = [_circlesPoints objectAtIndex:i * 2];
    LinePoint *curPoint = [_circlesPoints objectAtIndex:i * 2 + 1];
    CGPoint dirVector = ccpNormalize(ccpSub(curPoint.pos, prevPoint.pos));
    
    [self fillLineEndPointAt:curPoint.pos direction:dirVector radius:curPoint.width * 0.5f andColor:color];
  }
  [_circlesPoints removeAllObjects];
  
  glDisable(GL_DEPTH_TEST);
}


- (void)fillLineEndPointAt:(CGPoint)center direction:(CGPoint)aLineDir radius:(CGFloat)radius andColor:(ccColor4F)color
{
  int numberOfSegments = 32;
  LineVertex *vertices = malloc(sizeof(LineVertex) * numberOfSegments * 9);
  float anglePerSegment = (float)(M_PI / (numberOfSegments - 1));
  
  //! we need to cover M_PI from this, dot product of normalized vectors is equal to cos angle between them... and if you include rightVec dot you get to know the correct direction :)
  CGPoint perpendicular = ccpPerp(aLineDir);
  float angle = acosf(ccpDot(perpendicular, CGPointMake(0, 1)));
  float rightDot = ccpDot(perpendicular, CGPointMake(1, 0));
  if (rightDot < 0.0f) {
    angle *= -1;
  }
  
  CGPoint prevPoint = center;
  CGPoint prevDir = ccp(sinf(0), cosf(0));
  for (unsigned int i = 0; i < numberOfSegments; ++i) {
    CGPoint dir = ccp(sinf(angle), cosf(angle));
    CGPoint curPoint = ccp(center.x + radius * dir.x, center.y + radius * dir.y);
    vertices[i * 9 + 0].pos = center;
    vertices[i * 9 + 1].pos = prevPoint;
    vertices[i * 9 + 2].pos = curPoint;
    
    //! fill rest of vertex data
    for (unsigned int j = 0; j < 9; ++j) {
      vertices[i * 9 + j].z = j < 3 ? 1.0f : 2.0f;
      vertices[i * 9 + j].color = color;
    }
    
    //! add overdraw
    vertices[i * 9 + 3].pos = ccpAdd(prevPoint, ccpMult(prevDir, _overdraw));
    vertices[i * 9 + 3].color.a = 0;
    vertices[i * 9 + 4].pos = prevPoint;
    vertices[i * 9 + 5].pos = ccpAdd(curPoint, ccpMult(dir, _overdraw));
    vertices[i * 9 + 5].color.a = 0;
    
    vertices[i * 9 + 6].pos = prevPoint;
    vertices[i * 9 + 7].pos = curPoint;
    vertices[i * 9 + 8].pos = ccpAdd(curPoint, ccpMult(dir, _overdraw));
    vertices[i * 9 + 8].color.a = 0;
    
    prevPoint = curPoint;
    prevDir = dir;
    angle += anglePerSegment;
  }
  
  glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].pos);
  glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].color);
  glDrawArrays(GL_TRIANGLES, 0, numberOfSegments * 9);
  
  free(vertices);
}

- (NSMutableArray *)calculateSmoothLinePoints
{
  if ([_points count] > 2) {
    NSMutableArray *smoothedPoints = [NSMutableArray array];
    for (unsigned int i = 2; i < [_points count]; ++i) {
      LinePoint *prev2 = [_points objectAtIndex:i - 2];
      LinePoint *prev1 = [_points objectAtIndex:i - 1];
      LinePoint *cur = [_points objectAtIndex:i];
      
      CGPoint midPoint1 = ccpMult(ccpAdd(prev1.pos, prev2.pos), 0.5f);
      CGPoint midPoint2 = ccpMult(ccpAdd(cur.pos, prev1.pos), 0.5f);
      
      int segmentDistance = 2;
      float distance = ccpDistance(midPoint1, midPoint2);
      int numberOfSegments = MIN(128, MAX(floorf(distance / segmentDistance), 32));
      
      float t = 0.0f;
      float step = 1.0f / numberOfSegments;
      for (NSUInteger j = 0; j < numberOfSegments; j++) {
        LinePoint *newPoint = [[LinePoint alloc] init];
        newPoint.pos = ccpAdd(ccpAdd(ccpMult(midPoint1, powf(1 - t, 2)), ccpMult(prev1.pos, 2.0f * (1 - t) * t)), ccpMult(midPoint2, t * t));
        newPoint.width = powf(1 - t, 2) * ((prev1.width + prev2.width) * 0.5f) + 2.0f * (1 - t) * t * prev1.width + t * t * ((cur.width + prev1.width) * 0.5f);
        
        [smoothedPoints addObject:newPoint];
        t += step;
      }
      LinePoint *finalPoint = [[LinePoint alloc] init];
      finalPoint.pos = midPoint2;
      finalPoint.width = (cur.width + prev1.width) * 0.5f;
      [smoothedPoints addObject:finalPoint];
    }
    //! we need to leave last 2 points for next draw
    [_points removeObjectsInRange:NSMakeRange(0, [_points count] - 2)];
    return smoothedPoints;
  } else {
    return nil;
  }
}


- (void)draw
{
  ccColor4F color = {0, 0, 0, 1};
  [_renderTexture begin];
  NSMutableArray *smoothedPoints = [self calculateSmoothLinePoints];
  if (smoothedPoints) {
    [self drawLines:smoothedPoints withColor:color];
  }
  [_renderTexture end];
}


#pragma mark - Handling points


- (void)startNewLineFrom:(CGPoint)newPoint withSize:(CGFloat)aSize
{
  _connectingLine = NO;
  [self addPoint:newPoint withSize:aSize];
}

- (void)endLineAt:(CGPoint)aEndPoint withSize:(CGFloat)aSize
{
  [self addPoint:aEndPoint withSize:aSize];
  _finishingLine = YES;
}

- (void)addPoint:(CGPoint)newPoint withSize:(CGFloat)size
{
  LinePoint *point = [[LinePoint alloc] init];
  point.pos = newPoint;
  point.width = size;
  [_points addObject:point];
}


#pragma mark - Touch event handling


- (void)onEnter
{
  [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
  [super onEnter];
}

- (void)onExit
{
  [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
  [super onExit];
}   


- (CGPoint)getPoint:(UITouch *)touch {
  return [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
}


- (void)saveEvent:(UITouch *)touch {
  WBEvent *evt = [[WBEvent alloc] initWithTouch:touch];
  RESTOperation *op = [evt save];
  [op onCompletion:^{
    if (op.error) {
      NSLog(@"Error while saving: %@", [op.error localizedDescription]);
    }
  }];
  [op start];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint point = [self getPoint:touch];
  
  [_points removeAllObjects];
  [_velocities removeAllObjects];
  
  [self startNewLineFrom:point withSize:_penWidth];
  [self addPoint:point withSize:_penWidth];
  [self addPoint:point withSize:_penWidth];
  
  [self saveEvent:touch];
  return YES;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint point = [self getPoint:touch];
  float eps = 1.5f;
  if ([_points count] > 0) {
    float length = ccpLength(ccpSub([(LinePoint *)[_points lastObject] pos], point));
    
    if (length < eps) {
      return;
    }
  }
  //TODO: vary size
  [self addPoint:point withSize:_penWidth];
  
  [self saveEvent:touch];  
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint point = [self getPoint:touch];
  //TODO: vary size
  [self endLineAt:point withSize:_penWidth];
  
  [self saveEvent:touch];
}


- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self saveEvent:touch];
}


@end
