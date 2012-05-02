//
//  Database.m
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "Database.h"

#import "Configuration.h"
#import "Globals.h"

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>
#import "TDListener.h"
#import <TouchDB/TDServer.h>
#import <TouchDB/TDRouter.h>
#import <TouchDB/TDDatabase.h>


@interface Database () {
  CouchReplication* _pull;
//  CouchReplication* _push;
  CouchDatabase *_database;
  TDListener *_listener;
}
@end


@implementation Database

@synthesize database = _database;


+ (id)sharedInstance {
  static dispatch_once_t onceQueue;
  static Database *database = nil;
  
  dispatch_once(&onceQueue, ^{ database = [[self alloc] init]; });
  return database;
}


- (BOOL)connect:(NSError **)outError {
  gCouchLogLevel = 1;

  Configuration *conf = [[Globals sharedInstance] currentConfiguration];
  if (conf.username != nil && conf.password != nil) {
    // register credentials
    NSURLCredential* cred;
    cred = [NSURLCredential credentialWithUser:conf.username
                                      password:conf.password
                                   persistence:NSURLCredentialPersistencePermanent];
    NSURLProtectionSpace* space;
    space = [[NSURLProtectionSpace alloc] initWithHost:conf.hostname
                                                  port:conf.port
                                              protocol:conf.protocol
                                                 realm:conf.realm
                                  authenticationMethod:NSURLAuthenticationMethodDefault];
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:cred
                                                        forProtectionSpace:space];
  }
  { // set up database
    CouchTouchDBServer *server = [CouchTouchDBServer sharedInstance];
    if (server.error) {
      if (outError != nil) {
        *outError = server.error;
      }
      return NO;
    }

    _database = [server databaseNamed:conf.localDbname];
    
    NSError *error = nil;
    if ([_database ensureCreated:&error]) {
//      [self updateSyncURL:nil];
    } else {
      if (outError != nil) {
        *outError = server.error;
      }
      return NO;
    }

    [server tellTDServer:^(TDServer *tdServer) {
      NSLog(@"Starting listener");
      _listener = [[TDListener alloc] initWithTDServer:tdServer port:59840]; 
      [_listener start];
    }];

/*    
    __block BOOL created = YES;
    
    [server tellTDServer:^(TDServer *tdServer) {
      [tdServer tellDatabaseNamed:conf.localDbname to:^(TDDatabase *db) {
        NSError *error = nil;
        [db deleteDatabase:&error];
        
        _database = [server databaseNamed:conf.localDbname];

        if ([_database ensureCreated:&error]) {
          [self updateSyncURL:nil];
        } else {
          if (outError != nil) {
            *outError = server.error;
          }
          created = NO;
        }
        
        NSLog(@"Starting listener");
        _listener = [[TDListener alloc] initWithTDServer:tdServer port:59840]; 
        [_listener start];
      }];
    }];
 if (! created) {
 return NO;
 }
 */   
 
  }
  return YES;
}


- (void)disconnect {
  [self forgetSync];
  _database = nil;
}


- (CouchDesignDocument *)designDocumentWithName:(NSString *)name {
  return [self.database designDocumentWithName:name];
}


#pragma mark - TouchDB Sync


- (void)updateSyncURL:(NSString *)url
{
  NSLog(@"resetting sync");
  if (! self.database) {
    NSLog(@"no database!");
    return;
  }
  
  NSURL* newRemoteURL;
  if (url == nil) {
    Configuration *conf = [[Globals sharedInstance] currentConfiguration];
    NSLog(@"configuration: %@", conf.displayName);
    newRemoteURL = [NSURL URLWithString:conf.remoteUrl];
  } else {
    newRemoteURL = [NSURL URLWithString:url];
  }
  NSLog(@"remote URL: %@", newRemoteURL);
  
  if (newRemoteURL) {
    [self forgetSync];
    _pull = [self.database pullFromDatabaseAtURL:newRemoteURL];
    //    _push = [self.database pushToDatabaseAtURL:newRemoteURL];
    _pull.continuous = YES;
    //    _push.continuous = YES;
  }
}


- (void)forgetSync {
  [_pull stop];
  _pull = nil;
//  [_push stop];
//  _push = nil;
}


#pragma mark - Fetch methods


- (CouchQuery *)events
{
  NSString *name = @"events";
  CouchDesignDocument* design = [self designDocumentWithName: @"default"];
  [design defineViewNamed:name
                 mapBlock:^(NSDictionary* doc, void (^emit)(id key, id value)) {
                   id type = [doc objectForKey: @"type"];
                   if (type && [type isEqualToString:@"event"]) {
                     id index = [doc objectForKey:@"index"];
                     emit(index, doc);
                   }
                 }
                  version: @"1.0"];
  CouchQuery *query = [design queryViewNamed:name];
  return query;
}


#pragma mark - Listener

static NSString* GetServerPath() {
  NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];  
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                       NSUserDomainMask, YES);
  NSString* path = [paths objectAtIndex:0];
  path = [path stringByAppendingPathComponent: bundleID];
  path = [path stringByAppendingPathComponent: @"TouchDB"];
  NSError* error = nil;
  if (![[NSFileManager defaultManager] createDirectoryAtPath: path
                                 withIntermediateDirectories: YES
                                                  attributes: nil error: &error]) {
    NSLog(@"FATAL: Couldn't create TouchDB server dir at %@", path);
    exit(1);
  }
  return path;
}


- (void)listen
{
}


@end
