//
//  CouchPoint.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 27.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "CouchPoint.h"

#import "Globals.h"

@implementation CouchPoint

@dynamic x, y, w, index, type, version;


- (id)initWithNewDocumentInDatabase:(CouchDatabase *)database
{
  self = [super initWithNewDocumentInDatabase:database];
  if (self) {
    self.type = @"point";
    self.version = [[Globals sharedInstance] version];
  }
  return self;
}


- (void)setPosition:(CGPoint)pos {
  self.x = [NSNumber numberWithDouble:pos.x];
  self.y = [NSNumber numberWithDouble:pos.y];
}


- (CGPoint)position {
  CGPoint p = CGPointMake([self.x doubleValue], [self.y doubleValue]);
  return p;
}


- (void)setWidth:(float)width {
  self.w = [NSNumber numberWithFloat:width];
}


- (float)width {
  return [self.w floatValue];
}


@end
