//
//  POPImage.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POPImage : NSObject
+(void)saveJpg:(NSImage*)img path:(NSString*)path;
@end
