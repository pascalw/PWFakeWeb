//
//  ASIHTTPRequest+fakweb.m
//  PWFakeWeb
//
//  Created by Pascal Widdershoven on 02-10-11.
//  Copyright 2011 Pascal Widdershoven. All rights reserved.
//

#import "ASIHTTPRequest+fakweb.h"
#import "PWFakeWeb+private.h"

@implementation ASIHTTPRequest (fakeweb)

+ (void) load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	Class c = [ASIHTTPRequest class];
	Swizzle(c, @selector(startSynchronous), @selector(override_startSynchronous));
	Swizzle(c, @selector(responseString), @selector(override_responseString));
	Swizzle(c, @selector(responseStatusCode), @selector(override_responseStatusCode));
	Swizzle(c, @selector(startAsynchronous), @selector(override_startAsynchronous));
	
	[pool drain];
}

- (NSURL *) URIForOverride {
	return self.originalURL ? self.originalURL : self.url;
}

- (NSDictionary *) lookupOverride {
	return [PWFakeWeb overrideForURI: [self URIForOverride] method: self.requestMethod];
}

- (void) override_startSynchronous {
	NSDictionary *override = [self lookupOverride];
	
	if(override)
	{
		//just do nothing
	}
	else
	{
		return [self override_startSynchronous]; //call original implementation
	}
}

- (void) override_startAsynchronous {
	NSDictionary *override = [self lookupOverride];
	
	if(override)
	{
		//basically just do nothing again, just call the completionBlock after a small async delay
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * 1e9), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			dispatch_async( dispatch_get_main_queue(), ^{
				completionBlock();
			});
		});
	}
	else
	{
		return [self override_startAsynchronous]; //call original implementation
	}
}

- (NSString *) override_responseString {
	NSDictionary *override = [self lookupOverride];
	if(override)
	{
		return [override objectForKey: PWFakeWebRequestBodyKey];
	}
	else
	{
		return [self override_responseString]; //call original implementation
	}
}

- (int) override_responseStatusCode {
	NSDictionary *override = [self lookupOverride];
	
	if(override)
	{
		return [[override objectForKey: PWFakeWebRequestStatusKey] intValue];
	}
	else
	{
		return [self override_responseStatusCode]; //call original implementation
	}
}

@end
