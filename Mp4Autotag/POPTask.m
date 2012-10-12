//
//  POPTask.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/29/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import "POPTask.h"

@implementation POPTask
+(NSString*)launchedWithLaunchPathAndWaitReturnStdio:(NSString*)path options:(NSArray*)opts
{
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:path];
	[task setArguments:opts];
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[task standardOutput]];
	[task launch];
	[task waitUntilExit];
	NSData* data = [[[task standardOutput] fileHandleForReading] readDataToEndOfFile];
	NSString* info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString* rtn = [NSString stringWithString:info];
	info = nil;
	task = nil;
	return rtn;
}
@end
