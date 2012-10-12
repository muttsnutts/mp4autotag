//
//  POPFileMan.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POPFileMan : NSObject
+(NSString*) getTempFilePath;
+(NSString*) getTempFilePathWithExt:(NSString*)ext;
@end
