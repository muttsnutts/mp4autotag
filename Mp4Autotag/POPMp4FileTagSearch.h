//
//  POPMp4FileTagSearch.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POPMp4FileTag.h"

@interface POPMp4FileTagSearch : NSObject
@property (readonly) bool isMovie;
-(id) searchWithFileTag:(POPMp4FileTag*)tag /*tableView:(NSTableView*)tv*/;
-(POPMp4FileTag*) chooseResult:(int)idx;
-(NSString*) episodeString;
-(NSString*) seasonString;
-(NSString*) seriesString;
-(NSString*) searchString;
@end
