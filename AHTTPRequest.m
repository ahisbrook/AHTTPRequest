//
//  AHTTPRequest.m
//
//  Created by Adrienne Hisbrook on 6/13/13.
//

#import "AHTTPRequest.h"

@interface AHTTPRequest ()

@property (nonatomic) NSURLRequest *theRequest;

@end

@implementation AHTTPRequest

-(void)executeRequest {
    self.theRequest = (NSURLRequest*)self;
    NSHTTPURLResponse *tempResponse;
    NSError *tempErr;
    NSData *tempData = [NSURLConnection sendSynchronousRequest:self.theRequest returningResponse:&tempResponse error:&tempErr];
    
    if (tempData) {
        [self connectionDidEndWithResponse:tempResponse data:tempData error:tempErr];
    }
}

-(void)executeRequestAsync:(id<AHTTPRequestAsyncDelegate>)delegate {
    self.theRequest = (NSURLRequest*)self;
    [NSURLConnection sendAsynchronousRequest:self.theRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               [self connectionDidEndWithResponse:response data:data error:connectionError];
                           }];
}

-(void)connectionDidEndWithResponse:(NSURLResponse*)response data:(NSData*)data error:(NSError*)error {
    if (response) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        self.responseHeaders = httpResponse.allHeaderFields;
        self.responseStatusCode = [NSNumber numberWithInt:httpResponse.statusCode];
        NSLog(@"Response received");
    }
    if (data != nil && data.length > 0) {
        self.responseData = [NSMutableData dataWithData:data];
        
        NSError *err;
        self.responseObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:&err];
        self.responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Data received");
    }
    
    self.responseCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies;
    self.error = error;
    
    NSLog(@"COOKIE COUNT: %d", self.responseCookies.count);
    NSLog(@"STATUS CODE: %@", self.responseStatusCode);
    NSLog(@"HEADERS: %@", self.responseHeaders);
    NSLog(@"STRING: %@", self.responseString);
    NSLog(@"OBJECT: %@", self.responseObject);
    NSLog(@"ERROR: %@", self.error);
}

-(void)setHTTPBodyWithDictionary:(NSDictionary*)bodyDictionary {
    NSError *err;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:NSJSONWritingPrettyPrinted error:&err];
    self.HTTPBody = bodyData;
}

@end
