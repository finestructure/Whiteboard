//
//  GCD.h
//  elme
//
//  Created by Sven A. Schmidt on 20.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCD : NSObject

+ (void)runBlockInBackground:(void(^)())block;
+ (void)runBlockOnMainThread:(void(^)())block;

@end
