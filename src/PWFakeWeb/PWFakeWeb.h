//
//  PWFakeWeb.h
//  PWFakeWeb
//
//  Created by Pascal Widdershoven on 30-09-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PWFakeWebNetConnectNotAllowedException;

@interface PWFakeWeb : NSObject

+ (void) setAllowNetConnect: (BOOL) netConnect;
+ (BOOL) allowsNetConnect;

+ (void) registerURI: (NSString *) uri method: (NSString *) method body: (NSString *) body status: (int) status;
+ (void) registerURI: (NSString *) uri method: (NSString *) method body: (NSString *) body;
+ (void) clearRegistry;

@end
