//
//  AHTTPRequest.h
//
//  Created by Adrienne Hisbrook on 6/13/13.
//

#import <Foundation/Foundation.h>

@protocol AHTTPRequestAsyncDelegate <NSObject>
- (void)connectionEnded:(AHTTPRequest*)request;
@end

@interface AHTTPRequest : NSMutableURLRequest

@property (nonatomic) NSDictionary *responseHeaders;
@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSString *responseString;
@property (nonatomic) NSArray *responseCookies;
@property (nonatomic) NSNumber *responseStatusCode;
@property (nonatomic) NSError *error;

@property (nonatomic) id responseObject;

-(void)setHTTPBodyWithDictionary:(NSDictionary*)bodyDictionary;

-(void)executeRequest;
-(void)executeRequestAsync:(id<AHTTPRequestAsyncDelegate>)delegate;

@end
