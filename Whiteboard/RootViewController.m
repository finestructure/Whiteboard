//
//  RootViewController.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 29.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "RootViewController.h"

#import "Database.h"
#import "WhiteboardLayer.h"
#import "Replay.h"
#import "EchoLayer.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize canvas = _canvas;
@synthesize popover = _popover;

#pragma mark - Actions


- (IBAction)replayTapped:(id)sender
{
  CCDirector *director = [CCDirector sharedDirector];
  [director end];
  [director.view removeFromSuperview];
  director.view = nil;

  [self setupCocos2D];  
	[director pushScene:[Replay scene]];
  [director startAnimation];
}


- (IBAction)bonjourTapped:(id)sender event:(UIEvent *)event
{
  NSLog(@"bonjour");
  UIView *view = [[event.allTouches anyObject] view];
  BonjourBrowser *bb = [[BonjourBrowser alloc] initForType:@"_whiteboard._tcp"
                                                  inDomain:@"local"
                                             customDomains:nil
                                  showDisclosureIndicators:NO
                                          showCancelButton:NO];
  bb.delegate = self;
  self.popover = [[UIPopoverController alloc] initWithContentViewController:bb];
  [self.popover presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}



- (void)echoEvents
{
  NSLog(@"Starting echo");
  CCDirector *director = [CCDirector sharedDirector];
  [director end];
  [director.view removeFromSuperview];
  director.view = nil;
  
  [self setupCocos2D];  
	[director pushScene:[EchoLayer scene]];
  [director startAnimation];
}



#pragma mark - BonjourBrowserDelegate


- (NSString *)copyStringFromTXTDict:(NSDictionary *)dict which:(NSString*)which {
	// Helper for getting information from the TXT data
	NSData* data = [dict objectForKey:which];
	NSString *resultString = nil;
	if (data) {
		resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return resultString;
}


- (void) bonjourBrowser:(BonjourBrowser*)browser didResolveInstance:(NSNetService*)service {
	// Construct the URL including the port number
	// Also use the path, username and password fields that can be in the TXT record
	NSDictionary* dict = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
	NSString *host = [service hostName];
	
	NSString* user = [self copyStringFromTXTDict:dict which:@"u"];
	NSString* pass = [self copyStringFromTXTDict:dict which:@"p"];
	
	NSString* portStr = @"";
	
	// Note that [NSNetService port:] returns an NSInteger in host byte order
	NSInteger port = [service port];
	if (port != 0 && port != 80)
    portStr = [[NSString alloc] initWithFormat:@":%d",port];
	
	NSString* path = [self copyStringFromTXTDict:dict which:@"path"];
	if (!path || [path length]==0) {
    path = [[NSString alloc] initWithString:@"/"];
	} else if (![[path substringToIndex:1] isEqual:@"/"]) {
    NSString *tempPath = [[NSString alloc] initWithFormat:@"/%@",path];
    path = tempPath;
	}
	
	NSString* url = [[NSString alloc] initWithFormat:@"http://%@%@%@%@%@%@%@",
                   user?user:@"",
                   pass?@":":@"",
                   pass?pass:@"",
                   (user||pass)?@"@":@"",
                   host,
                   portStr,
                   path];
	
  NSLog(@"service: %@", service);
  NSLog(@"url: %@", url);
  
  [self.popover dismissPopoverAnimated:YES];
  [[Database sharedInstance] updateSyncURL:url];
  [self echoEvents];
}


#pragma mark - Init


- (void)setupCocos2D
{
	CCGLView *glView = [CCGLView viewWithFrame:[self.canvas bounds]
                                 pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
                                 depthFormat:0	//GL_DEPTH_COMPONENT24_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil
                               multiSampling:NO
                             numberOfSamples:0];
  glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.canvas insertSubview:glView atIndex:0];

  CCDirector *director = [CCDirector sharedDirector];
  director.view = glView;
  director.displayStats = YES;
  director.animationInterval = 1/60.;
  director.delegate = self;
  director.projection = kCCDirectorProjection2D;
	if(! [director enableRetinaDisplay:YES]) {
		CCLOG(@"Retina Display Not supported");
  }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupCocos2D];
	[[CCDirector sharedDirector] pushScene:[WhiteboardLayer scene]];
  [[CCDirector sharedDirector] startAnimation];
}


- (void)viewDidUnload
{
  [self setCanvas:nil];
  [super viewDidUnload];
  [[CCDirector sharedDirector] end];
}


- (void)viewWillAppear:(BOOL)animated
{
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  [super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


@end
