//
//  POPAutomatedAutotagWindow.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "POPProgressWindow.h"

@interface POPAutomatedAutotagWindow : NSWindow
//subclassing
-(id)initWithContentRect:(NSRect)contentRect 
			   styleMask:(NSUInteger)windowStyle 
				 backing:(NSBackingStoreType)bufferingType 
				   defer:(BOOL)deferCreation;
-(void)awakeFromNib;

//properties
@property (weak) IBOutlet NSTableView *queueView;
@property (unsafe_unretained) IBOutlet POPProgressWindow *progressWindow;
@property (weak) IBOutlet NSTableView *propertyView;
@property (weak) IBOutlet NSSplitView *vsplit;

//actions
- (IBAction)closeClick:(id)sender;
- (IBAction)undoClick:(id)sender;

//functions
- (bool)autotagQueue:(NSArray*)q;
@end