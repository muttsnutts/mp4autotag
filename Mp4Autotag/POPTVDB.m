//
//  POPTVDB.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import "POPTVDB.h"
#import "POPXMLReader.h"
#import "POPImage.h"

@implementation POPTVDB
-(id) init;{
	return [super init];
}

-(id) queryURL:(NSURL*)url
{
	NSError* error;
	NSData* data = [NSData dataWithContentsOfURL:url];
	if(data == nil) return nil;
	return [POPXMLReader dictionaryForXMLString:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n" withString:@""] error:&error];
}


-(NSArray*)searchTVFor:(NSString*)series 
				season:(NSString*)season 
			   episode:(NSString*)episode 
		  coverArtType:(NSInteger)coverArtType 
			 useITunes:(BOOL)useITunes{
	
	NSMutableArray *rtn = [NSMutableArray array];
	
	int episearchnum = [episode intValue];
	int seasearchnum = [season intValue];
	int addWatermark = [[[NSUserDefaults standardUserDefaults] valueForKey:@"addWatermark"] intValue];
	
	POPMp4FileTag* tag = nil;
	
	NSURL* url = [NSURL URLWithString:[@"http://www.thetvdb.com/api/GetSeries.php?seriesname=" stringByAppendingString:[series stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSDictionary* resSeries = [self queryURL:url];
	NSLog(@"%@", resSeries);
	
	NSMutableArray* seriesIds = [NSMutableArray array];
	
	id serobj = [[resSeries objectForKey:@"Data"] objectForKey:@"Series"];
	NSArray* serary = nil;
	if([serobj isKindOfClass:[NSDictionary class]])
	{
		serary = [NSArray arrayWithObjects:(NSDictionary*)serobj, nil];
	}
	else if ([serobj isKindOfClass:[NSArray class]])
	{
		serary = (NSArray*)serobj;
	}
	if(serary != nil)
	{
		for(int i = 0; i < [serary count]; i++)
		{
			NSDictionary* serdic = (NSDictionary*)[serary objectAtIndex:i];
			NSString* seriesid = [[[serdic objectForKey:@"seriesid"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			[seriesIds addObject:seriesid];
		}
	}
	
	NSMutableArray* r1m = [NSMutableArray array];
	NSMutableArray* r2m = [NSMutableArray array];
	NSMutableArray* r3m = [NSMutableArray array];
	NSMutableArray* r4m = [NSMutableArray array];
	for(int i = 0; i < [seriesIds count]; i++)
	{
		url = [NSURL URLWithString:[NSString stringWithFormat: @"http://www.thetvdb.com/api/A8B8C9F3D5621481/series/%@/all/en.xml", [seriesIds objectAtIndex:i]]];
		NSLog(@"%@",url);
		NSDictionary* resAll = [self queryURL:url];
		
		NSString* actors = [POPXMLReader safeDictionaryGet:resAll 
											  path:[NSArray arrayWithObjects:@"Data", @"Series", @"Actors", @"text",nil]];
		/*if([actors length] > 4) actors = [[actors substringWithRange:NSMakeRange(1, [actors length] - 2)] stringByReplacingOccurrencesOfString:@"|" withString:@" / "];*/
		NSString* genres = [POPXMLReader safeDictionaryGet:resAll 
											  path:[NSArray arrayWithObjects:@"Data", @"Series", @"Genre", @"text",nil]];
		/*if([genres length] > 4) genres = [[genres substringWithRange:NSMakeRange(1, [genres length] - 2)] stringByReplacingOccurrencesOfString:@"|" withString:@" / "];*/
		NSString* tvshow = [POPXMLReader safeDictionaryGet:resAll 
											  path:[NSArray arrayWithObjects:@"Data", @"Series", @"SeriesName", @"text",nil]];
		NSString* tvnetwork = [POPXMLReader safeDictionaryGet:resAll 
												 path:[NSArray arrayWithObjects:@"Data", @"Series", @"Network", @"text",nil]];
		NSString* releaseDate = [POPXMLReader safeDictionaryGet:resAll 
												   path:[NSArray arrayWithObjects:@"Data", @"Series", @"FirstAired", @"text",nil]];
		NSString* seriesposter = [NSString stringWithFormat:@"posters/%@-1.jpg",[seriesIds objectAtIndex:i]];
		
		id epiobj = [[resAll objectForKey:@"Data"] objectForKey:@"Episode"];
		int epinum = 0;
		int seanum = 0;
		int absnum = 0;
		NSArray* epiary = nil;
		if([epiobj isKindOfClass:[NSDictionary class]])
		{
			epiary = [NSArray arrayWithObjects:(NSDictionary*)epiobj, nil];
		}
		else if([epiobj isKindOfClass:[NSArray class]])
		{
			epiary = (NSArray*)epiobj;
		}
		if(epiary != nil){
			for(int i = 0; i < [epiary count]; i++){
				NSDictionary* epidic = (NSDictionary*)[epiary objectAtIndex:i];
				NSLog(@"%@",epidic);
				epinum = [[POPXMLReader safeDictionaryGet:epidic 
											 path:[NSArray arrayWithObjects:@"EpisodeNumber", @"text",nil]] intValue];
				seanum = [[POPXMLReader safeDictionaryGet:epidic 
											 path:[NSArray arrayWithObjects:@"SeasonNumber", @"text",nil]] intValue];
				absnum = [[POPXMLReader safeDictionaryGet:epidic 
											 path:[NSArray arrayWithObjects:@"absolute_number", @"text",nil]] intValue];
				NSString* epiname = [POPXMLReader safeDictionaryGet:epidic 
													   path:[NSArray arrayWithObjects:@"EpisodeName", @"text",nil]];
				NSString* descstr = [POPXMLReader safeDictionaryGet:epidic 
													   path:[NSArray arrayWithObjects:@"Overview", @"text",nil]];
				NSString* poster = [POPXMLReader safeDictionaryGet:epidic
													  path:[NSArray arrayWithObjects:@"filename", @"text", nil]];
				
				int dbID = [[POPXMLReader safeDictionaryGet:epidic 
											   path:[NSArray arrayWithObjects:@"id", @"text",nil]] intValue];
				NSString* writer = [POPXMLReader safeDictionaryGet:epidic
													  path:[NSArray arrayWithObjects:@"Writer", @"text", nil]];
				NSString* director = [POPXMLReader safeDictionaryGet:epidic
														path:[NSArray arrayWithObjects:@"Director", @"text", nil]];
				tag = [[POPMp4FileTag alloc] init];
				[tag setProperty:@"Artists" value:actors];
				[tag setProperty:@"TV Show" value:tvshow];
				[tag setProperty:@"Grouping" value:tvshow];
				[tag setProperty:@"TV Episode Number" value:epiname];
				[tag setProperty:@"Genre" value:genres];
				[tag setProperty:@"TV Network" value:tvnetwork];
				[tag setProperty:@"Release Date" value:releaseDate];
				[tag setProperty:@"Copyright" value:releaseDate];
				[tag setProperty:@"TV Episode" value:[NSString stringWithFormat:@"%i", epinum]];
				[tag setProperty:@"TV Season" value:[NSString stringWithFormat:@"%i", seanum]];
				[tag setProperty:@"cnID" value:[NSString stringWithFormat:@"%i", absnum]];
				[tag setProperty:@"Album" value:epiname];
				[tag setProperty:@"Long Description" value:descstr];
				[tag setProperty:@"Short Description" value:descstr];
				[tag setProperty:@"Composer" value:writer];
				[tag setProperty:@"Album Artist" value:director];
				[tag setProperty:@"Media Type" value:@"tvshow"];
				[tag setProperty:@"Name" value:[NSString stringWithFormat:@"%@ - S%0.2iE%0.2i - %@", tvshow, seanum, epinum, epiname]];
				[tag setDbID:dbID];
				
				NSImage *img = nil;
				NSURL* imgurl = nil;
				//now set the image based on using:
												//season poster, 
												//episode poster, 
												//watermarked season poster, 
												//itunes season poster, or 
												//itunes season watermarked poster.
												
				//first see if we are using episode posters
				if(coverArtType == 1)
				{
					if([poster compare:@""] != 0) {
						imgurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thetvdb.com/banners/%@", poster]];
						img = [[NSImage alloc] initWithContentsOfURL:imgurl];
					}
				}
				
				//If that did not work then we are using season posters
				if(img == nil)
				{
					//now see if we are using itunes
					BOOL uit = useITunes;
					if(uit)
					{
						//try to get an itunes image
						img = [POPImage getITunesImageForSeries:tvshow season:seanum];
						//if not gotten, set useITunes to false
						if(img == nil) uit = NO;
					}
					//if that failed or we are not using iTunes
					if(!uit)
					{
						if([poster compare:@""] != 0) {
							imgurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thetvdb.com/banners/%@", seriesposter]];
							img = [[NSImage alloc] initWithContentsOfURL:imgurl];
						} 
					}
				}
				
				//if we got an image then lets see if we should watermark it
				if(img != nil && addWatermark > 0)
				{
					[img lockFocus];
					NSString *wm = [NSString stringWithFormat:@"S%0.2iE%0.2i ", [[tag property:@"TV Season"] intValue], [[tag property:@"TV Episode"] intValue]];
					float fs = [img alignmentRect].size.width/4.3;
					if([img alignmentRect].size.height < [img alignmentRect].size.width)
					{
						fs = [img alignmentRect].size.height/4.3;
					}
					NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
					[style setAlignment:NSRightTextAlignment];
					NSDictionary* atts = [NSDictionary dictionaryWithObjectsAndKeys:
											   [NSColor colorWithCalibratedWhite:0.0 alpha:0.3], NSForegroundColorAttributeName,
											   [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.3], NSBackgroundColorAttributeName,
											   style, NSParagraphStyleAttributeName,
											   [NSFont fontWithName:@"Helvetica-Bold" size:fs], NSFontAttributeName,
											   nil ];
					[wm drawInRect:[img alignmentRect] withAttributes:atts];
					[img unlockFocus];
				}
				
				//set img to the tag...
				[tag setImage:img];
				
				if(epinum == episearchnum && seanum == seasearchnum){
					if([series compare:tvshow options:NSCaseInsensitiveSearch] == 0)
						[r1m insertObject:tag atIndex:0];
					else
						[r1m addObject:tag];
				}
				else if(epinum == episearchnum){
					[r2m addObject:tag];
				}
				else if(absnum == episearchnum){
					[r3m addObject:tag];
				}
				else if(seanum == seasearchnum){
					[r4m addObject:tag];
				}
				tag = nil;
			}
		}
		rtn = [NSMutableArray arrayWithArray:[[[r1m arrayByAddingObjectsFromArray:r2m] arrayByAddingObjectsFromArray:r3m] arrayByAddingObjectsFromArray:r4m]];
		NSLog(@"%@", resAll);
	}
	
	return rtn;
}
-(POPMp4FileTag*)getMp4FileTagWithId:(int)dbId {
	return nil;
}
@end
