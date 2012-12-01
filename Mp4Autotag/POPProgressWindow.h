//
//  POPProgressWindow.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface POPProgressWindow : NSWindow
@property (weak) IBOutlet NSTextField *messageTextField;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
-(void) show:(NSString*)msg 
	 progress:(double)percent;
-(void) showSheet:(NSString*)msg 
		 progress:(double)percent
		   parent:(NSWindow*)parent;
-(void) hide;
@end
