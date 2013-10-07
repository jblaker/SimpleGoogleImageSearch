//
//  Google_Image_SearchTests.m
//  Google Image SearchTests
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ImageRequestManager.h"

@interface Google_Image_SearchTests : XCTestCase

@end

@implementation Google_Image_SearchTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEndpointURL {
  ImageRequestManager *imageRequestManager = [[ImageRequestManager alloc] init];
  
  NSString *urlString = [[imageRequestManager endpointURLForQueryString:@"test" startingAt:0 andNumberOfResults:5] absoluteString];
  XCTAssertTrue([urlString isEqualToString:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=test&rsz=5&start=0"], @"URL Absolute String should match");
  
  urlString = [[imageRequestManager endpointURLForQueryString:@"test" startingAt:5 andNumberOfResults:8] absoluteString];
  XCTAssertTrue([urlString isEqualToString:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=test&rsz=8&start=5"], @"URL Absolute String should match");
}

@end
