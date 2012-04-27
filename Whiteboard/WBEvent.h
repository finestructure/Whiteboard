//
//  CouchPoint.h
//  Whiteboard
//
//  Created by Sven A. Schmidt on 27.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>

@interface WBEvent : CouchModel

@property (nonatomic, copy) NSNumber *x;
@property (nonatomic, copy) NSNumber *y;
@property (nonatomic, copy) NSNumber *index;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *phase;

@property (nonatomic, assign) CGPoint position;

- (id)initWithTouch:(UITouch *)touch;

@end
