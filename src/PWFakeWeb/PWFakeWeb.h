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

// Allow or deny net connect. Default YES.
// When set to NO, an exception will be thrown if a request is made but no fake was registred.
+ (void) setAllowNetConnect: (BOOL) netConnect;
+ (BOOL) allowsNetConnect;

// Register an URI to fake. URIs can be specified by regular expression.
+ (void) registerURI: (NSString *) uri method: (NSString *) method body: (NSString *) body status: (int) status;
+ (void) registerURI: (NSString *) uri method: (NSString *) method body: (NSString *) body;

// Fakes are stored for the duration of the running application / test
// This method clears all the registred fakes to start with a clean state.
+ (void) clearRegistry;

@end
