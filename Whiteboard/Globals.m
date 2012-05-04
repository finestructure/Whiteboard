//
//  Constants.m
//  Sinma
//
//  Created by Sven A. Schmidt on 10.01.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "Globals.h"

#import "Configuration.h"

NSString * const kUuidDefaultsKey = @"UUID";
NSString * const kConfigurationDefaultsKey = @"Configuration";


@implementation Globals


+ (Globals *)sharedInstance {
  static Globals *sharedInstance = nil;
  
  if (sharedInstance) {
    return sharedInstance;
  }
  
  @synchronized(self) {
    if (! sharedInstance) {
      sharedInstance = [[Globals alloc] init];
    }
    
    return sharedInstance;
  }
}


- (NSString *)version {
  static NSString *version = nil;
  
  if (version) {
    return version;
  }
  
  @synchronized(self) {
    if (! version) {
      version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
  }
  
  return version;
}


- (NSString *)deviceUuid {
  static NSString *uuid = nil;
  
  if (uuid != nil) {
    return uuid;
  }
  
  @synchronized(self) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id res = [defaults objectForKey:kUuidDefaultsKey];
    if (res != nil) {
      uuid = res;
    } else {
      CFUUIDRef _uuid;
      CFStringRef _uuidStr;
      _uuid = CFUUIDCreate(NULL);
      _uuidStr = CFUUIDCreateString(NULL, _uuid);
      uuid = (__bridge_transfer NSString *)_uuidStr;
      CFRelease(_uuid);
      [defaults setObject:uuid forKey:kUuidDefaultsKey];
    }
  }
  
  return uuid;
}


- (NSArray *)configurations {
  static NSMutableArray *configurations = nil;
  if (configurations != nil) {
    return configurations;
  }
  @synchronized(self) {
    if (configurations == nil) {
      configurations = [NSMutableArray array];
      {
        Configuration *c = [[Configuration alloc] init];
        c.name = @"TEST";
        c.displayName = @"Test (thebe.local)";
        c.hostname = @"thebe.local";
        c.port = 5984;
        c.protocol = @"http";
        c.dbname = @"whiteboard_test";
        c.localDbname = c.dbname;
        [configurations addObject:c];
      }
    }
  }
  return configurations;
}


- (Configuration *)defaultConfiguration {
  return [[self configurations] objectAtIndex:0];
}


- (Configuration *)configurationWithName:(NSString *)confName {
  for (Configuration *c in [self configurations]) {
    if ([c.name isEqualToString:confName]) {
      return c;
    }
  }
  return nil;
}


- (Configuration *)currentConfiguration {
  NSString *confName = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigurationDefaultsKey];
  Configuration *conf = [self configurationWithName:confName];
  if (conf == nil) {
    //NSLog(@"Warning: configuration '%@' specified in defaults no found in allowed configurations, using default.", confName);
    conf = [self defaultConfiguration];
  }
  return conf;
}


- (NSUInteger)nextSequenceId {
  static NSUInteger sequenceId = 0;
  @synchronized(self) {
    return sequenceId++;
  }
}


- (void)registerDefaults {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  Configuration *defaultConf = [self defaultConfiguration];
  NSDictionary *appdefaults = [NSDictionary dictionaryWithObject:defaultConf.name forKey:kConfigurationDefaultsKey];
  [defaults registerDefaults:appdefaults];
  [defaults synchronize];
  
  // observe key changes
  [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:kConfigurationDefaultsKey options:NSKeyValueObservingOptionNew context:nil];
}


#pragma mark - KVO


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context
{
  if (object == [NSUserDefaults standardUserDefaults]) {
    NSLog(@"KVO for %@, new conf: %@", keyPath, [[Globals sharedInstance] currentConfiguration].displayName);
    // send notification
  }
}


@end

