//
//  PWFakeWeb.m
//  PWFakeWeb
//
//  Created by Pascal Widdershoven on 30-09-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWFakeWeb.h"
#import "ASIHTTPRequest.h"
#import <objc/runtime.h> 
#import <objc/message.h>

#define KEY_BODY @"body"
#define KEY_STATUS @"status"

NSString * const PWFakeWebRequestKey = @"PWFakeWebRequestKey";
NSString * const PWFakeWebNetConnectNotAllowedException = @"PWFakeWebNetConnectNotAllowedException";

static BOOL allowNetConnect;
static NSMutableDictionary *overrides;

void Swizzle(Class c, SEL orig, SEL new);

@interface PWFakeWeb ()

+ (NSString *) keyForURI: (NSString *) uri method: (NSString *) method;

@end

@implementation PWFakeWeb

+ (void) initialize {
	overrides = [NSMutableDictionary new];
	
	Class c = [ASIHTTPRequest class];
	Swizzle(c, @selector(startSynchronous), @selector(override_startSynchronous));
	Swizzle(c, @selector(responseString), @selector(override_responseString));
	Swizzle(c, @selector(responseStatusCode), @selector(override_responseStatusCode));
	Swizzle(c, @selector(startAsynchronous), @selector(override_startAsynchronous));
	
	allowNetConnect = YES;
}

+ (void) setAllowNetConnect: (BOOL) netConnect {
	allowNetConnect = netConnect;
}

+ (void) registerURI: (NSString *) uri method: (NSString *) method body: (NSString *) body status: (int) status {
	NSString *key = [self keyForURI: uri method: method];
	NSDictionary *value = [NSDictionary dictionaryWithObjectsAndKeys: 
						   body, KEY_BODY,
						   [NSNumber numberWithInt: status], KEY_STATUS
						   , nil];
	
	[overrides setValue: value forKey: key];
}

+ (void) registerURI: (NSString *) uri method: (NSString *) method body: (NSString *) body {
	[self registerURI: uri method: method body: body status: 200];
}

+ (NSString *) keyForURI: (NSString *) uri method: (NSString *) method {
	return [NSString stringWithFormat: @"%@ %@", method, uri];
}

+ (NSDictionary *) overrideForURI: (NSURL *) uri method: (NSString *) method {
	NSString *matchAgainst = [self keyForURI: uri.absoluteString method: method];
	
	for(NSString *key in overrides)
	{
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: key
										options: NSRegularExpressionCaseInsensitive error: nil];
		
		if([regex numberOfMatchesInString: matchAgainst options: 0 range: NSMakeRange(0, [matchAgainst length])] > 0)
		{
			return [overrides objectForKey: key];
		}
	}
	
	return nil;
}

+ (void) clearRegistry {
	[overrides removeAllObjects];
}

+ (void) raiseNetConnectExceptionForURI: (NSURL *) uri method: (NSString *) method {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject: [self keyForURI: uri.absoluteString method: method] forKey: PWFakeWebRequestKey];
	
	@throw [NSException exceptionWithName: PWFakeWebNetConnectNotAllowedException reason: PWFakeWebNetConnectNotAllowedException userInfo: userInfo];
}

@end

@implementation ASIHTTPRequest (fakeweb)

- (NSURL *) URIForOverride {
	return self.originalURL ? self.originalURL : self.url;
}

- (void) override_startSynchronous {
	if(! [PWFakeWeb overrideForURI: [self URIForOverride] method: self.requestMethod])
	{
		if(! allowNetConnect)
		{
			[PWFakeWeb raiseNetConnectExceptionForURI: [self URIForOverride] method: self.requestMethod];
		}
		else
		{
			return [self override_startSynchronous]; //call original implementation
		}
	}
	else
	{
		//just do nothing
	}
}

- (void) override_startAsynchronous {
	if(! [PWFakeWeb overrideForURI: [self URIForOverride] method: self.requestMethod])
	{
		if(! allowNetConnect)
		{
			[PWFakeWeb raiseNetConnectExceptionForURI: [self URIForOverride] method: self.requestMethod];
		}
		else
		{
			return [self override_startAsynchronous]; //call original implementation
		}
	}
	else
	{
		//basically just do nothing again, just call the completionBlock after a small async delay
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * 1e9), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			dispatch_async( dispatch_get_main_queue(), ^{
				completionBlock();
			});
		});
	}
}

- (NSString *) override_responseString {
	NSDictionary *override = [PWFakeWeb overrideForURI: [self URIForOverride] method: self.requestMethod];
	if(override)
	{
		return [override objectForKey: KEY_BODY];
	}
	else
	{
		return [self override_responseString]; //call original implementation
	}
}

- (int) override_responseStatusCode {
	NSDictionary *override = [PWFakeWeb overrideForURI: [self URIForOverride] method: self.requestMethod];
	
	if(override)
	{
		return [[override objectForKey: KEY_STATUS] intValue];
	}
	else
	{
		return [self override_responseStatusCode];
	}
}

@end

/* Code by Mike Ash http://www.cocoadev.com/index.pl?MethodSwizzling */
void Swizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
		method_exchangeImplementations(origMethod, newMethod);
}
