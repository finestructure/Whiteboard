//
//  GCD.m
//  elme
//
//  Created by Sven A. Schmidt on 20.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "GCD.h"

@implementation GCD


+ (void)runBlockInBackground:(void(^)())block {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


+ (void)runBlockOnMainThread:(void(^)())block {
  dispatch_async(dispatch_get_main_queue(), block);
}


@end
