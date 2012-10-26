//
//  POPImage.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POPImage : NSObject
+(void)saveJpg:(NSImage*)img path:(NSString*)path;
+(NSImage*)getITunesImageForSeries:(NSString*)series season:(NSInteger)season; 
+(NSImage*)getITunesImageForMovie:(NSString*)movie;
@end
