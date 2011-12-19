//
//  PWFakeWeb+private.h
//  PWFakeWeb
//
//  Created by Pascal Widdershoven on 02-10-11.
//  Copyright 2011 Pascal Widdershoven. All rights reserved.
//

extern NSString * const PWFakeWebRequestKey;
extern NSString * const PWFakeWebRequestBodyKey;
extern NSString * const PWFakeWebRequestStatusKey;

void Swizzle(Class c, SEL orig, SEL new);

@interface PWFakeWeb (private)

+ (NSDictionary *) overrideForURI: (NSURL *) uri method: (NSString *) method;

@end