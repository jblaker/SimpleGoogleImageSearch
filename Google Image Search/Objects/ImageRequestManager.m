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

@interface ImageRequestManager ()

@property (nonatomic, strong) NSString *queryString;

@end

@implementation ImageRequestManager

@synthesize queryString=_queryString;

+ (id)imageRequestWithSearchQueryString:(NSString *)queryString success:(SucessfulSearchBlock)successBlock failure:(FailedSearchBlock)failureBlock {
  
  ImageRequestManager *imageRequestManager = [[ImageRequestManager alloc] init];
  
  [imageRequestManager setQueryString:queryString];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[imageRequestManager endpointURLForQueryString:queryString startingAt:0 andNumberOfResults:6]];
  
  AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
  
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

- (void)fetchMoreImageResultsStartingAt:(int)startAt success:(SucessfulSearchBlock)successBlock failure:(FailedSearchBlock)failureBlock {
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[self endpointURLForQueryString:_queryString startingAt:startAt andNumberOfResults:6]];
  
  AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
  
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
  
}

- (NSURL *)endpointURLForQueryString:(NSString *)queryString startingAt:(int)startAt andNumberOfResults:(int)numberOfResults {
  NSString *urlString = [[NSString stringWithFormat:@"%@%@&rsz=%i&start=%i&imgsz=small", kBaseEndpointURL, queryString, numberOfResults, startAt] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
  NSURL *queryURL = [NSURL URLWithString:urlString];
  return queryURL;
}

@end
