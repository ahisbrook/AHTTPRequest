//
//  AHTTPRequest.m
//  Created by Adrienne Hisbrook on 6/13/13.
//

#import "AHTTPRequest.h"

@implementation AHTTPRequest
static NSURLRequest* _theRequest = nil;

-(void)executeRequest {
    _theRequest = (NSURLRequest*)self;
    NSHTTPURLResponse *tempResponse;
    NSError *tempErr;
    NSData *tempData = [NSURLConnection sendSynchronousRequest:_theRequest returningResponse:&tempResponse error:&tempErr];
    
    if (tempData) {
        [self connectionDidEndWithResponse:tempResponse data:tempData error:tempErr];
    }
}

-(void)executeRequestAsync:(id<AHTTPRequestAsyncDelegate>)delegate {
    _theRequest = (NSURLRequest*)self;;
    [NSURLConnection sendAsynchronousRequest:_theRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               [self connectionDidEndWithResponse:response data:data error:error];
                               [delegate connectionEnded:self];
                           }];
}

-(void)connectionDidEndWithResponse:(NSURLResponse*)response data:(NSData*)data error:(NSError*)error {
    if (response) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        self.responseHeaders = httpResponse.allHeaderFields;
        self.responseStatusCode = [NSNumber numberWithInt:httpResponse.statusCode];
        NSLog(@"Response received");
    }
    if (data) {
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

/*
 Convenience method for creating API requests
 NOTE: 'methodName' refers to the API method, and 'httpMethod' is the http method
 
 Example:
 
 [AHTTPRequest requestWithURLString:@"http://www.myservicehost.com/api/"
 methodName:@"Users/GetUser"
 parameters:@{@"userid":@"jdoe42"}
 httpMethod:@"GET"
 useQueryStrings:YES];
 
 would return a get request with a url of "http://www.myservicehost.com/api/Users/GetUser?userid=jdoe42"
 */

+(AHTTPRequest*)requestWithURLString:(NSString*)baseUrl
                          methodName:(NSString*)methodName
                          parameters:(NSDictionary*)params
                          httpMethod:(NSString*)httpMethod
                     useQueryStrings:(BOOL)qs
{
    AHTTPRequest *request = [AHTTPRequest new];
    
    NSString *urlString = [baseUrl stringByAppendingString:methodName];
    
    if (qs) {
        NSString *queryString = @"?";
        int i = 0;
        for (NSString *key in [params keyEnumerator]) {
            queryString = [queryString stringByAppendingFormat:@"%@=%@",key,[params objectForKey:key]];
            i++;
            if (i < [params count]) {
                queryString = [queryString stringByAppendingString:@"&"];
            }
        }
        urlString = [urlString stringByAppendingString:queryString];
    }
    else {
        if (params != nil) {
            [request setHTTPBodyWithDictionary:params];
        }
    }
    NSLog(@"URL: %@", urlString);;
    [request setURL:[NSURL URLWithString:urlString]];
    
    // Set request options
    [request setHTTPMethod:httpMethod];
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:@"application/json" forKey:@"Accept"];
    [headers setObject:@"application/json" forKey:@"content-type"];
    [headers setObject:[NSString stringWithFormat:@"%d",request.HTTPBody.length] forKey:@"content-length"];
    
    [request setAllHTTPHeaderFields:headers];
    
    return request;
}

@end
