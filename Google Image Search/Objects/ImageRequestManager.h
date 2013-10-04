//
//  ImageRequestManager.h
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SucessfulSearchBlock)(NSDictionary *response);
typedef void(^FailedSearchBlock)(NSError *error);

@interface ImageRequestManager : NSObject

+ (id)imageRequestWithSearchQueryString:(NSString *)queryString success:(SucessfulSearchBlock)successBlock failure:(FailedSearchBlock)failureBlock;
- (NSURL *)endpointURLForQueryString:(NSString *)queryString andNumberOfResults:(int)numberOfResults;

@end
