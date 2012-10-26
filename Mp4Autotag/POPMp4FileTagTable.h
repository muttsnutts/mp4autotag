//
//  POPMp4FileTagTable.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/29/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POPAppDelegate.h"
#import "POPMp4FileTag.h"
#import "POPLoadingWindow.h"

@interface POPMp4FileTagTable : NSObject

@property (readwrite) NSMutableArray* mp4tags;
@property (readwrite) NSTableView* propertyView;
@property (readwrite) NSImageCell* propertyImageView;
@property (readwrite) POPLoadingWindow* loadWnd;

-(id) initWithParent:(id)parent; 
-(void) addMp4FileTag:(POPMp4FileTag*)tag at:(int)idx;
-(void) addMp4Files:(NSArray*) urls atIndex:(unsigned int)atIdx;
-(void) removeMp4FileTagAt:(int)idx;
-(void) saveMp4FileTagAt:(int)idx;
-(void) saveAllMp4FileTags;
-(void) reloadAll;

@end
