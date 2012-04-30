//
//  AppDelegate.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 25.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

//
//  AppDelegate.m
//  Smooth Drawing


#import "cocos2d.h"

#import "AppDelegate.h"
#import "Database.h"
#import "LineDrawer.h"
#import "Replay.h"

@interface AppDelegate () {
}

@end

@implementation AppDelegate

@synthesize window = _window;


#pragma mark - Helpers

- (void)setupCocos {
  // Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
  
	// When in iPhone RetinaDisplay, iPad, iPad RetinaDisplay mode, CCFileUtils will append the "-hd", "-ipad", "-ipadhd" to all loaded files
	// If the -hd, -ipad, -ipadhd files are not found, it will load the non-suffixed version
	[CCFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[CCFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "" (empty string)
	[CCFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
  
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
}


#pragma mark - Init and app lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self setupCocos];
  
  [self.window makeKeyAndVisible];
  
  NSError *error = nil;
  if (! [[Database sharedInstance] connect:&error]) {
    NSLog(@"Failed to connect to database: %@", [error localizedDescription]);
  }
  
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
  [[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
  [[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
  [[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
  [[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
