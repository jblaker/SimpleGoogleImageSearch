//
//  ImageCell.m
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/5/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import "ImageCell.h"
#import "UIImageView+WebCache.h"

@interface ImageCell () {
  UIImageView *_imageView;
}

@end

@implementation ImageCell


- (id)initWithFrame:(CGRect)frame {
 
  if (self = [super initWithFrame:frame]) {    
    // The Image View
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [[self contentView] addSubview:_imageView];
  }
  
  return self;
  
}

- (void)loadImage:(NSDictionary *)imageDict {
  NSURL *imageURL = [NSURL URLWithString:[imageDict objectForKey:@"url"]];
  [_imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"MissingImage"]];
}

@end
