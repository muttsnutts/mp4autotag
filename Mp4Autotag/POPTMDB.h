//
//  POPTMDB.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POPMp4FileTag.h"

@interface POPTMDB : NSObject
-(id) init;
-(NSArray*)searchMoviesFor:(NSString*)search useITunes:(BOOL)useITunes;
-(POPMp4FileTag*)getMp4FileTagWithId:(int)dbId useITunes:(BOOL)useITunes;
@end
