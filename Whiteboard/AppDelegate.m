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
#import "LineDrawer.h"

@interface AppDelegate () {
  __weak CCDirectorIOS *_director;
}

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[self.window bounds]
                                 pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
                                 depthFormat:0	//GL_DEPTH_COMPONENT24_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil
                               multiSampling:NO
                             numberOfSamples:0];
  
	_director = (CCDirectorIOS*) [CCDirector sharedDirector];
  
	_director.wantsFullScreenLayout = YES;
  
	// Display FSP and SPF
	[_director setDisplayStats:YES];
  
	// set FPS at 60
	[_director setAnimationInterval:1.0/60];
  
	// attach the openglView to the director
	[_director setView:glView];
  
	// for rotation and other messages
	[_director setDelegate:self];
  
	// 2D projection
	[_director setProjection:kCCDirectorProjection2D];
  //	[director setProjection:kCCDirectorProjection3D];
  
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [_director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
  
  [self.window addSubview:_director.view];
  [self.window makeKeyAndVisible];
  
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
  
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
  CCScene *scene = [CCScene node];
  [scene addChild:[LineDrawer node]];
	[_director pushScene: scene]; 
  
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
  [_director pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
  [_director resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
  [_director stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
  [_director startAnimation];
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
