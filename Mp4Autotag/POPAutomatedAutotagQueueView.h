//
//  POPAutomatedAutotagQueueView.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POPAutomatedAutotagPropertyView.h"

@interface POPAutomatedAutotagQueueView : NSObject
@property (readwrite) NSArray* queue;
@property (readwrite) NSTableView* propertyView;
@property (readwrite) POPAutomatedAutotagPropertyView* propertyViewer;
- (void) refresh;
@end
