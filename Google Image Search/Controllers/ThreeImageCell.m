//
//  ThreeImageCell.m
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import "ThreeImageCell.h"
#import "UIImageView+WebCache.h"

@implementation ThreeImageCell

@synthesize imageDicts=_imageDicts, imageViewLeft=_imageViewLeft, imageViewCenter=_imageViewCenter, imageViewRight=_imageViewRight;

- (void)loadImages {
  
  if (_imageDicts.count >= 1) {
    // First Image
    NSString *leftImageURLString = [[_imageDicts objectAtIndex:0] objectForKey:@"url"];
    [_imageViewLeft setImageWithURL:[NSURL URLWithString:leftImageURLString]];
  }
  
  if (_imageDicts.count >= 2) {
    // Second Image
    NSString *centerImageURLString = [[_imageDicts objectAtIndex:1] objectForKey:@"url"];
    [_imageViewCenter setImageWithURL:[NSURL URLWithString:centerImageURLString]];
  }
  
  if (_imageDicts.count == 3) {
    // Third Image
    NSString *rightImageURLString = [[_imageDicts objectAtIndex:2] objectForKey:@"url"];
    [_imageViewRight setImageWithURL:[NSURL URLWithString:rightImageURLString]];
  }
  
}

@end
