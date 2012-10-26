//
//  POPImage.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import "POPImage.h"

@implementation POPImage
+(void)saveJpg:(NSImage*)img path:(NSString*)path
{
	NSData *imageData = [img TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:path atomically:NO];
}

+(NSImage*)getITunesImageForSeries:(NSString*)series season:(NSInteger)season
{
	NSError *error;
	NSString* search_url_str_fmt = @"https://itunes.apple.com/search?term=%@+%i&media=tvShow&entity=tvSeason";
	NSString* search_url_str = [NSString stringWithFormat:search_url_str_fmt, [series stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], season];
	NSLog(@"ITUNES CONNECT: %@", search_url_str);
	NSURL* url = [NSURL URLWithString:search_url_str];
	NSData* data = [NSData dataWithContentsOfURL:url];
	if(data == nil) return nil;
	NSDictionary* res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	NSLog(@"%@",res);
	if(![[res valueForKey:@"resultCount"] isKindOfClass:[NSNumber class]]) return nil;
	if([[res valueForKey:@"resultCount"] intValue] == 0) return nil;
	if(![[res valueForKey:@"results"] isKindOfClass:[NSArray class]]) return nil;
	NSArray *resary = [res valueForKey:@"results"];
	NSDictionary *f = [resary objectAtIndex:0];
	if(![[f valueForKey:@"artworkUrl100"] isKindOfClass:[NSString class]]) return nil;
	NSString* img_path = [[f valueForKey:@"artworkUrl100"] stringByReplacingOccurrencesOfString:@"100x100" withString:@"600x600"];
	return [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:img_path]]; 
}

+(NSImage*)getITunesImageForMovie:(NSString*)movie
{
	NSError *error;
	NSString* search_url_str_fmt = @"https://itunes.apple.com/search?term=%@&media=movie";
	NSString* search_url_str = [NSString stringWithFormat:search_url_str_fmt, [movie stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	NSLog(@"ITUNES CONNECT: %@", search_url_str);
	NSURL* url = [NSURL URLWithString:search_url_str];
	NSData* data = [NSData dataWithContentsOfURL:url];
	if(data == nil) return nil;
	NSDictionary* res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	NSLog(@"%@",res);
	if(![[res valueForKey:@"resultCount"] isKindOfClass:[NSNumber class]]) return nil;
	if([[res valueForKey:@"resultCount"] intValue] == 0){
		search_url_str = [NSString stringWithFormat:search_url_str_fmt, [[movie substringToIndex:[movie length]-7] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
		url = [NSURL URLWithString:search_url_str];
		data = [NSData dataWithContentsOfURL:url];
		if(data == nil) return nil;
		res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
		NSLog(@"%@",res);
		if(![[res valueForKey:@"resultCount"] isKindOfClass:[NSNumber class]]) return nil;
		if([[res valueForKey:@"resultCount"] intValue] == 0) return nil;
	}
	if(![[res valueForKey:@"results"] isKindOfClass:[NSArray class]]) return nil;
	NSArray *resary = [res valueForKey:@"results"];
	NSDictionary *f = [resary objectAtIndex:0];
	if(![[f valueForKey:@"artworkUrl100"] isKindOfClass:[NSString class]]) return nil;
	NSString* img_path = [[f valueForKey:@"artworkUrl100"] stringByReplacingOccurrencesOfString:@"100x100" withString:@"600x600"];
	return [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:img_path]]; 
}
@end
