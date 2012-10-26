//
//  POPTMDB.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import "POPTMDB.h"
#import "POPMp4FileTag.h"
#import "POPImage.h"

@implementation POPTMDB
{
	NSDictionary* _config;
	NSDictionary* _searchResultsJSON;
}

-(id) init
{
	NSError *error;
	NSURL* configUrl = [NSURL URLWithString: @"http://api.themoviedb.org/3/configuration?api_key=ae802ff2638e8a186add7079dda29e03"];
	_config = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:configUrl] options:NSJSONReadingMutableLeaves error:&error];
	_searchResultsJSON = nil;
	return [super init];
}

-(NSString*)imageBaseUrl
{
	return [[_config objectForKey:@"images"] objectForKey:@"base_url"];
}

-(id) queryURL:(NSURL*)url
{
	NSError* error;
	//NSLog(@"movieURL: %@", searchUrl);
	NSData* data = [NSData dataWithContentsOfURL:url];
	if(data == nil) return nil;
	return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
}

-(NSDictionary*) getMovieWithId:(NSNumber*)mid
{
	return [self queryURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@?api_key=ae802ff2638e8a186add7079dda29e03", [mid stringValue]]]];
}

-(POPMp4FileTag*)getMp4FileTagWithId:(int)dbId useITunes:(BOOL)useITunes
{
	NSNumber* mid = [NSNumber numberWithInt:dbId];
	POPMp4FileTag* tag = [[POPMp4FileTag alloc] init];
	NSDictionary* res = [self getMovieWithId:mid];
	NSString* val;
	
	[tag setProperty:@"Media Type" value:@"movie"];
	[tag setDbID:[[self safeGet:res key:@"id"] intValue]];	
	[tag setProperty:@"Release Date" value:[self safeGet:res key:@"release_date"]];
	[tag setProperty:@"TV Show" value:[self safeGet:res key:@"title"]];
	[tag setProperty:@"Album" value:[self safeGet:res key:@"title"]];
	[tag setProperty:@"Name" value:[NSString stringWithFormat:@"%@ (%@)", [tag property:@"TV Show"], [tag property:@"Release Date"]]];
	
	NSArray* arts = [self getCastForMovieId:mid];
	if([arts count] != 0)
	{
		val = @"";
		for(int i = 0; i < [arts count]; i++)
		{
			NSDictionary *art = [arts objectAtIndex:i];
			val = [val stringByAppendingString:[art objectForKey:@"name"]];
			if(i < ([arts count] - 1))
			{
				val = [val stringByAppendingString:@"|"];
			}
			
		}
		[tag setProperty:@"Artist" value:val];
	}
	else {
		[tag setProperty:@"Artist" value:@""];
	}
	
	NSArray* gnrs = [res objectForKey:@"genres"];
	if([gnrs count] != 0)
	{
		val = @"";
		for(int i = 0; i < [gnrs count]; i++)
		{
			NSDictionary *gnr = [gnrs objectAtIndex:i];
			val = [val stringByAppendingString:[gnr objectForKey:@"name"]];
			if(i < ([gnrs count] - 1))
			{
				val = [val stringByAppendingString:@"|"];
			}
			
		}
		[tag setProperty:@"Genre" value:val];
	}
	else {
		[tag setProperty:@"Genre" value:@""];
	}
	
	val = [self safeGet:res key:@"overview"];
	[tag setProperty:@"Short Description" value:val];
	[tag setProperty:@"Long Description" value:val];
	
	NSString* posterPath = [self safeGet:res key:@"poster_path"];
	NSImage* img = nil;
	if([posterPath compare:@""] == 0 || useITunes)
	{
		img = [POPImage getITunesImageForMovie:[tag property:@"Name"]];
	}
	
	if(img == nil && [posterPath compare:@""] != 0)
	{
		NSString* urlStr = [[self imageBaseUrl] stringByAppendingFormat:@"w500%@", posterPath];
		NSURL* imgUrl = [NSURL URLWithString:urlStr];
		img = [[NSImage alloc] initWithContentsOfURL:imgUrl];	
	}
	
	[tag setImage:img];
	
	return tag;
}

-(NSString*) safeGet:(NSDictionary*) dic key:(NSString*)key {
	NSString* rtn = nil;
	if(dic != nil)
		if([dic isKindOfClass:[NSDictionary class]])
			if((rtn = [dic objectForKey:key]) != nil)
				if([rtn isKindOfClass:[NSString class]] || [rtn isKindOfClass:[NSNumber class]])
					return rtn;
	return @"";
}

-(NSArray*) getCastForMovieId:(NSNumber *)mid
{
	NSDictionary* rtn = [self queryURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@/casts?api_key=ae802ff2638e8a186add7079dda29e03", [mid stringValue]]]];
	return [rtn objectForKey:@"cast"];
}

-(NSArray*) searchMoviesFor:(NSString*)search useITunes:(BOOL)useITunes
{
	_searchResultsJSON = [self queryURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://api.themoviedb.org/3/search/movie?api_key=ae802ff2638e8a186add7079dda29e03&query=", [[search stringByReplacingOccurrencesOfString:@"&" withString:@"and"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];//[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	NSArray* res = [_searchResultsJSON objectForKey:@"results"];
	NSMutableArray* rtn = [[NSMutableArray alloc] init];
	for(int i = 0; i < [res count]; i++){
		NSDictionary* dic = [res objectAtIndex:i];
		NSLog(@"%@s", dic);
		if(dic != nil)
		{
			POPMp4FileTag* tag = [[POPMp4FileTag alloc] init];
			
			[tag setProperty:@"Media Type" value:@"movie"];
			[tag setDbID:[[self safeGet:dic key:@"id"] intValue]];	
			[tag setProperty:@"Release Date" value:[self safeGet:dic key:@"release_date"]];
			[tag setProperty:@"TV Show" value:[self safeGet:dic key:@"title"]];
			[tag setProperty:@"Name" value:[NSString stringWithFormat:@"%@ (%@)", [tag property:@"TV Show"], [tag property:@"Release Date"]]];
			
			NSString* posterPath = [self safeGet:dic key:@"poster_path"];
			NSImage* img = nil;
			if([posterPath compare:@""] == 0 || useITunes)
			{
				img = [POPImage getITunesImageForMovie:[tag property:@"Name"]];
			}
			
			if(img == nil && [posterPath compare:@""] != 0)
			{
				NSString* urlStr = [[self imageBaseUrl] stringByAppendingFormat:@"w500%@", posterPath];
				NSURL* imgUrl = [NSURL URLWithString:urlStr];
				img = [[NSImage alloc] initWithContentsOfURL:imgUrl];
			}
			
			[tag setImage:img];
			/*
			NSString* posterPath = [self safeGet:dic key:@"poster_path"];
			if([posterPath compare:@""] != 0)
			{
				NSString* urlStr = [[self imageBaseUrl] stringByAppendingFormat:@"w500%@", posterPath];
				NSURL* imgUrl = [NSURL URLWithString:urlStr];
				NSImage* img = [[NSImage alloc] initWithContentsOfURL:imgUrl];
				[tag setImage:img];
			}
			*/
			[rtn addObject:tag];
		}
	}
	return rtn;
}

@end


















