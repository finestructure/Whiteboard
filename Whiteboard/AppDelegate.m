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

- (void)setupTextures {
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


- (void)setupDirectorWithView:(CCGLView *)glView {
	CCDirectorIOS *director = (CCDirectorIOS*) [CCDirector sharedDirector];
  
	director.wantsFullScreenLayout = YES;
  
	// Display FSP and SPF
	[director setDisplayStats:YES];
  
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
  
	// attach the openglView to the director
	[director setView:glView];
  
	// for rotation and other messages
	[director setDelegate:self];
  
	// 2D projection
	[director setProjection:kCCDirectorProjection2D];
  //	[director setProjection:kCCDirectorProjection3D];
  
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
}


#pragma mark - Init and app lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  //TODO: is this needed at all?
  [self setupTextures];
  
	// Create the main window
//	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[self.window bounds]
                                 pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
                                 depthFormat:0	//GL_DEPTH_COMPONENT24_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil
                               multiSampling:NO
                             numberOfSamples:0];
  
  [self setupDirectorWithView:glView];
  
  [self.window addSubview:glView];
  
//  CGFloat height = 44;
//  UIToolbar *toobar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.window.frame.size.height - height, self.window.frame.size.width, height)];
//  UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStyleBordered target:nil action:nil];
//  toobar.items = [NSArray arrayWithObject:button];
//  
//  [self.window addSubview:toobar];
  
  [self.window makeKeyAndVisible];
  
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
  CCScene *scene = [CCScene node];
  [scene addChild:[LineDrawer node]];
	[[CCDirector sharedDirector] pushScene: scene];
  
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
