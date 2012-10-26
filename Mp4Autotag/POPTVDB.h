//
//  POPTVDB.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POPMp4FileTag.h"

@interface POPTVDB : NSObject
-(id) init;
-(NSArray*)searchTVFor:(NSString*)series 
				season:(NSString*)season 
			   episode:(NSString*)episode 
		  coverArtType:(NSInteger)coverArtType
			 useITunes:(BOOL)useITunes;
-(POPMp4FileTag*)getMp4FileTagWithId:(int)dbId;
@end
