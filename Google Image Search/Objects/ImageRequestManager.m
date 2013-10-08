//
//  ImageRequestManager.m
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import "ImageRequestManager.h"
#import "AFJSONRequestOperation.h"
#import "CoreDataManager.h"

#define kBaseEndpointURL @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="

@interface ImageRequestManager ()

@property (nonatomic, strong) NSString *queryString;

@end

@implementation ImageRequestManager

@synthesize queryString=_queryString, coreDataManager=_coreDataManager;

- (void)imageRequestWithSearchQueryString:(NSString *)queryString success:(SucessfulSearchBlock)successBlock failure:(FailedSearchBlock)failureBlock {
  
  [self setQueryString:queryString];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[self endpointURLForQueryString:queryString startingAt:0 andNumberOfResults:8]];
  
  AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successBlock && [[responseObject objectForKey:@"responseStatus"] intValue] == 200) {
      successBlock(responseObject);
    }
    if ( failureBlock && [[responseObject objectForKey:@"responseStatus"] intValue] != 200) {
      failureBlock(nil);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if (failureBlock) {
      failureBlock(error);
    }
  }];
  
  [operation start];
  
  [self saveToSearchHistory];
  
}

- (void)saveToSearchHistory {
  [[CoreDataManager sharedManager] saveSearch:_queryString];
}

- (void)fetchMoreImageResultsStartingAt:(int)startAt success:(SucessfulSearchBlock)successBlock failure:(FailedSearchBlock)failureBlock {
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[self endpointURLForQueryString:_queryString startingAt:startAt andNumberOfResults:8]];
  
  AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successBlock && [[responseObject objectForKey:@"responseStatus"] intValue] == 200) {
      successBlock(responseObject);
    }
    if ( failureBlock && [[responseObject objectForKey:@"responseStatus"] intValue] != 200) {
      failureBlock(nil);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if (failureBlock) {
      failureBlock(error);
    }
  }];
  
  [operation start];
  
}

- (NSURL *)endpointURLForQueryString:(NSString *)queryString startingAt:(int)startAt andNumberOfResults:(int)numberOfResults {
  NSString *urlString = [[NSString stringWithFormat:@"%@%@&rsz=%i&start=%i&size=med", kBaseEndpointURL, queryString, numberOfResults, startAt] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
  NSURL *queryURL = [NSURL URLWithString:urlString];
  return queryURL;
}

@end
