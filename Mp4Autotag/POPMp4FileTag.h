//
//  POPMp4FileTag.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/29/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POPMp4FileTag : NSObject

@property (readonly) NSDictionary* properties;
@property (readonly) NSString* filename;
@property (readwrite) int coverArtPieces;
@property (readwrite) NSImage* image;
@property (readwrite) int dbID;
@property (readwrite) bool customSeriesSearch;

-(id) init;
-(id) initWithFile:(NSString*)filename;
-(bool) mergeData:(POPMp4FileTag*)data;
-(bool) save;
-(NSString*) property:(NSString*)prop;
-(bool) setProperty:(NSString*)prop value:(NSString*)val;
-(bool) rename;

@end
