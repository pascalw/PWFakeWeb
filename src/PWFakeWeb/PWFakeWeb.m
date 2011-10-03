//
//  PWFakeWeb.m
//  PWFakeWeb
//
//  Created by Pascal Widdershoven on 30-09-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWFakeWeb.h"
#import "PWFakeWeb+private.h"
#import <objc/runtime.h> 
#import <objc/message.h>

NSString * const PWFakeWebRequestKey = @"PWFakeWebRequestKey";
NSString * const PWFakeWebNetConnectNotAllowedException = @"PWFakeWebNetConnectNotAllowedException";
NSString * const PWFakeWebRequestBodyKey = @"PWFakeWebRequestBodyKey";
NSString * const PWFakeWebRequestStatusKey = @"PWFakeWebRequestStatusKey";

static BOOL allowNetConnect;
static NSMutableDictionary *overrides;

@interface PWFakeWeb ()

+ (NSString *) keyForURI: (NSString *) uri method: (NSString *) method;
+ (void) raiseNetConnectExceptionForURI: (NSURL *) uri method: (NSString *) method;

@end

@implementation PWFakeWeb

#pragma mark - internal

+ (void) initialize {
	overrides = [NSMutableDictionary new];
	allowNetConnect = YES;
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
	
	if(! [self allowsNetConnect])
	{
		[self raiseNetConnectExceptionForURI: uri method: method];
	}
	
	return nil;
}

+ (void) raiseNetConnectExceptionForURI: (NSURL *) uri method: (NSString *) method {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject: [self keyForURI: uri.absoluteString method: method] forKey: PWFakeWebRequestKey];
	
	@throw [NSException exceptionWithName: PWFakeWebNetConnectNotAllowedException reason: PWFakeWebNetConnectNotAllowedException userInfo: userInfo];
}

#pragma mark - public

+ (void) setAllowNetConnect: (BOOL) netConnect {
	allowNetConnect = netConnect;
}

+ (BOOL) allowsNetConnect {
	return allowNetConnect;
}

+ (void) registerURI: (NSString *) uri method: (NSString *) method body: (NSString *) body status: (int) status {
	NSString *key = [self keyForURI: uri method: method];
	NSDictionary *value = [NSDictionary dictionaryWithObjectsAndKeys: 
						   body, PWFakeWebRequestBodyKey,
						   [NSNumber numberWithInt: status], PWFakeWebRequestStatusKey
						   , nil];
	
	[overrides setValue: value forKey: key];
}

+ (void) registerURI: (NSString *) uri method: (NSString *) method body: (NSString *) body {
	[self registerURI: uri method: method body: body status: 200];
}


+ (void) clearRegistry {
	[overrides removeAllObjects];
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
