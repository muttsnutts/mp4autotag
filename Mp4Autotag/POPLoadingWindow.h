//
//  POPLoadingWindow.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/29/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface POPLoadingWindow : NSWindow
-(void) show:(NSString*)msg;
-(void) hide;
@property (weak) IBOutlet NSTextField *msgLabel;
@end
