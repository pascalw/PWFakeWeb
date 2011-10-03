//
//  PWFakeWebSpec.m
//  PWFakeWeb
//
//  Created by Pascal Widdershoven on 30-09-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define KIWI_DISABLE_MACRO_API
#import "Kiwi.h"
#import "ASIHTTPRequest+fakweb.h"

SPEC_BEGIN(PWFakeWebSpec)

__block NSURL *uri = nil;
__block ASIHTTPRequest *req = nil;

describe(@"PWFakeWebSpec", ^{
	
	beforeAll(^{
		uri = [NSURL URLWithString: @"http://apple.com"];
	});
	
	beforeEach(^{
		req = [ASIHTTPRequest requestWithURL: uri];
		[PWFakeWeb clearRegistry];
	});
	
	context(@"Synchronous requests", ^{
		
		context(@"Asbolute URIs", ^{
		
			it(@"Should override web calls with specified expected body and status code", ^{
				
				[PWFakeWeb registerURI: uri.absoluteString method: @"GET" body: @"Error 500" status: 500];
				
				[req setRequestMethod: @"GET"];
				[req startSynchronous];
				
				[[[req responseString] should] equal: @"Error 500"];
				[[theValue([req responseStatusCode]) should] equal: theValue(500)];
			});
			
			it(@"Should", ^{
				[PWFakeWeb registerURI: @"http://apple.com/(.*)" method: @"GET" body: @"Error 500" status: 500];
				[PWFakeWeb setAllowNetConnect: NO];
				
				req = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: @"http://apple.com/iphone"]];
				[[theBlock(^{
					[req startSynchronous];
				}) shouldNot] raise];
			});
		});
		
		context(@"Regex matches", ^{
			
			it(@"Should override web calls with specified expected body and status code", ^{
				[PWFakeWeb registerURI: @"http://(.*)\\.com" method: @"GET" body: @"Error 500" status: 500];
				
				[req setRequestMethod: @"GET"];
				[req startSynchronous];
				
				[[[req responseString] should] equal: @"Error 500"];
				[[theValue([req responseStatusCode]) should] equal: theValue(500)];
				
				req = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: @"http://foobar.com"]];
				[req setRequestMethod: @"GET"];
				[req startSynchronous];
				
				[[[req responseString] should] equal: @"Error 500"];
				[[theValue([req responseStatusCode]) should] equal: theValue(500)];
			});
			
		});
	});
	
	context(@"ASynchronous requests", ^{
		
		it(@"Should override web calls with specified expected body and status code", ^{
			[PWFakeWeb registerURI: uri.absoluteString method: @"GET" body: @"" status: 301];
			
			[req setRequestMethod: @"GET"];
			
			__block NSString *response = nil;
			[req setCompletionBlock: ^{
				response = [req responseString];
			}];
			
			[req startAsynchronous];
			
			[[[req responseString] shouldEventuallyBeforeTimingOutAfter(2.0)] equal: @""];
			[[theValue([req responseStatusCode]) shouldEventuallyBeforeTimingOutAfter(2.0)] equal: theValue(301)];
		});

	});
	
	describe(@"AllowNetConnect", ^{
		
		beforeEach(^{
			[PWFakeWeb registerURI: @"(.*)\\.(com|org|net)" method: @"GET" body: @"" status: 404];
			
			req = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: @"http://pwiddershoven.nl/blog/index.html"]];
			[req setRequestMethod: @"GET"];
		});
		
		it(@"Should not affect non-matched URIs if allowNetConnect", ^{
			[PWFakeWeb setAllowNetConnect: YES];
			
			[req startSynchronous];
			[[theValue([req responseStatusCode]) shouldNot] equal: theValue(404)];
			[[[req responseString] shouldNot] equal: @""];
		});
		
		it(@"Should raise an exception if NetConnect is not allowed", ^{
			[PWFakeWeb setAllowNetConnect: NO];
			
			[[theBlock(^{
				[req startSynchronous];
			}) should] raiseWithName: PWFakeWebNetConnectNotAllowedException];
		});
	});

});

SPEC_END;