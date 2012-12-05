//
//  POPFileMan.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import "POPFileMan.h"

@implementation POPFileMan

+(NSString*) getTempFilePath
{
	return [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", ([NSDate timeIntervalSinceReferenceDate] * 1000.0), @"txt"]];
}

+(NSString*) getTempFilePathWithExt:(NSString*)ext
{
	return [NSString stringWithFormat:@"%@.%@", [self getTempFilePath], ext];
}

@end
