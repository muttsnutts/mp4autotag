//
//  POPTask.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POPTask : NSTask
+(NSString*)launchedWithLaunchPathAndWaitReturnStdio:(NSString*)path options:(NSArray*)opts;
@end
