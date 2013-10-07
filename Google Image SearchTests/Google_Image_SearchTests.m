//
//  Google_Image_SearchTests.m
//  Google Image SearchTests
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ImageRequestManager.h"
#import "ImageSearchViewController.h"
#import "AppDelegate.h"
#import "CoreDataManager.h"

static id mockCoreDataManager = nil;

@implementation CoreDataManager (UnitTests)

+ (id)sharedManager {
  return mockCoreDataManager;
}

@end

@interface Google_Image_SearchTests : XCTestCase {
  ImageRequestManager *_imageRequestManager;
}

@end

@implementation Google_Image_SearchTests

- (void)setUp {
  [super setUp];
  _imageRequestManager = [[ImageRequestManager alloc] init];
}

- (void)tearDown {
  [super tearDown];
  _imageRequestManager = nil;
}

- (void)testEndpointURL {
  NSString *urlString = [[_imageRequestManager endpointURLForQueryString:@"test" startingAt:0 andNumberOfResults:5] absoluteString];
  XCTAssertTrue([urlString isEqualToString:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=test&rsz=5&start=0"], @"URL Absolute String should match");
  
  urlString = [[_imageRequestManager endpointURLForQueryString:@"test" startingAt:5 andNumberOfResults:8] absoluteString];
  XCTAssertTrue([urlString isEqualToString:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=test&rsz=8&start=5"], @"URL Absolute String should match");
}

- (void)testImageRequestManagerCalled {
  ImageSearchViewController *vc = [[ImageSearchViewController alloc] initWithCollectionViewLayout:[PSUICollectionViewFlowLayout new]];
  id mockManager = [OCMockObject mockForClass:[ImageRequestManager class]];
  
  [vc setImageRequestManager:mockManager];
  
  [[mockManager expect] imageRequestWithSearchQueryString:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
  
  [vc doSearchWithString:@"beer"];
  
  [mockManager verify];
}

- (void)testImageRequestManagerCalledAgain {
  ImageSearchViewController *vc = [[ImageSearchViewController alloc] initWithCollectionViewLayout:[PSUICollectionViewFlowLayout new]];
  id mockManager = [OCMockObject mockForClass:[ImageRequestManager class]];
  
  [vc setImageRequestManager:mockManager];
  
  [[mockManager expect] fetchMoreImageResultsStartingAt:0 success:[OCMArg any] failure:[OCMArg any]];
  
  [vc requestMoreImages];
  
  [mockManager verify];
}

- (void)testSaveSearchGetsCalled {
  
  mockCoreDataManager = [OCMockObject mockForClass:[CoreDataManager class]];
  
  [[mockCoreDataManager expect] saveSearch:[OCMArg any]];
  
  [_imageRequestManager saveToSearchHistory];
  
  [mockCoreDataManager verify];
  
  mockCoreDataManager = nil;
}

- (void)testSaveContextGetsCalled {
  
  mockCoreDataManager = [[CoreDataManager alloc] init];
  
  id mockAppDelegate = [OCMockObject mockForClass:[AppDelegate class]];
  
  [[UIApplication sharedApplication] setDelegate:mockAppDelegate];
  
  [[mockAppDelegate expect] saveContext];

  [[CoreDataManager sharedManager] saveSearch:@"beer"];
  
  [mockAppDelegate verify];
  
}

@end
