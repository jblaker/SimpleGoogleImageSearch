//
//  ImageRequestManager.h
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CoreDataManager;

typedef void(^SucessfulSearchBlock)(NSDictionary *response);
typedef void(^FailedSearchBlock)(NSError *error);

@interface ImageRequestManager : NSObject

@property (nonatomic, strong) CoreDataManager *coreDataManager;

- (void)imageRequestWithSearchQueryString:(NSString *)queryString success:(SucessfulSearchBlock)successBlock failure:(FailedSearchBlock)failureBlock;
- (void)fetchMoreImageResultsStartingAt:(int)startAt success:(SucessfulSearchBlock)successBlock failure:(FailedSearchBlock)failureBlock;
- (NSURL *)endpointURLForQueryString:(NSString *)queryString startingAt:(int)startAt andNumberOfResults:(int)numberOfResults;
- (void)saveToSearchHistory;

@end
