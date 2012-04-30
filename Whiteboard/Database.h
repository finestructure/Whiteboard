//
//  Database.h
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CouchDatabase;
@class CouchDesignDocument;
@class CouchQuery;
@class Project;
@class TDListener;

@interface Database : NSObject

@property (weak, readonly) CouchDatabase *database;
@property (weak, readonly) TDListener *listener;

+ (Database *)sharedInstance;
- (BOOL)connect:(NSError **)outError;
- (void)disconnect;
- (CouchDesignDocument *)designDocumentWithName:(NSString *)name;
- (void)updateSyncURL:(NSString *)url;

- (CouchQuery *)events;

@end
