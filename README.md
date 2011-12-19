# PWFakeWeb

PWFakeWeb is inspired by the ruby [fakeweb gem](http://fakeweb.rubyforge.org/). It allows you to stub out HTTP calls, for example through [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest/). Ideal for testing HTTP related code.

PWFakeWeb comes with a fakeweb implementation for ASIHTTPRequest. PWFakeWeb however is only loosely coupled to ASIHTTPRequest, allowing you to use PWFakeWeb to override calls in any HTTP library. For an example how to do this, checkout the `ASIHTTPRequest+fakeweb.m` source code.

## Getting started

To get started link the PWFakeWeb static library into your testing target (for a walkthrough, see [here](http://stackoverflow.com/questions/6124523/linking-a-static-library-to-an-ios-project-in-xcode-4/6124872#6124872)).

Now all you need to do is `#import ASIHTTPRequest+fakeweb.m` into your test and off you go!

## Examples

Registring fakes:

	[PWFakeWeb registerURI: @"http://pwiddershoven.nl" method: @"GET" body: @"Hello, world!"];

	NSURL *url = [NSURL URLWithString: @"http://pwiddershoven.nl"];

	ASIHTTPRequest *request =  [ASIHTTPRequest requestWithURL: url];
	[request startSynchronous];

	[request responseString]; => @"Hello, world!"

You can also match URIs with regular expressions, like so:

	[PWFakeWeb registerURI: @"http://google\.(com|nl|co\.uk)/(.*)" method: @"GET" body: @"Hello, world!"];

And set status codes:

  [PWFakeWeb registerURI: @"http://google.com" method: @"POST" body: @"" status: 500];

	
See the specs in `src/PWFakeWebSpecs/PWFakeWebSpec.m` for a full usage example.

