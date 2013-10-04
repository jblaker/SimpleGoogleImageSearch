//
//  ImageRequestManager.m
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import "ImageRequestManager.h"
#import "AFJSONRequestOperation.h"

#define kBaseEndpointURL @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="
#define kNumberOfResults 8

@implementation ImageRequestManager

+ (id)imageRequestWithSearchQueryString:(NSString *)queryString success:(SucessfulSearchBlock)successBlock failure:(FailedSearchBlock)failureBlock {
  
  ImageRequestManager *imageRequestManager = [[ImageRequestManager alloc] init];
  
  AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[imageRequestManager endpointURLForQueryString:queryString andNumberOfResults:kNumberOfResults]]];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successBlock) {
      successBlock(responseObject);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if (failureBlock) {
      failureBlock(error);
    }
  }];
  
  [operation start];
  
  return imageRequestManager;
  
}

- (NSURL *)endpointURLForQueryString:(NSString *)queryString andNumberOfResults:(int)numberOfResults {
  NSString *urlString = [[NSString stringWithFormat:@"%@%@&rsz=%i", kBaseEndpointURL, queryString, numberOfResults] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
  NSURL *queryURL = [NSURL URLWithString:urlString];
  return queryURL;
}

@end
