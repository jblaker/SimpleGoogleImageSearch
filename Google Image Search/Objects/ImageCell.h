//
//  ImageCell.h
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/5/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionViewCell.h"

@interface ImageCell : PSUICollectionViewCell

@property (nonatomic, retain) UIImageView *image;
- (void)loadImage:(NSDictionary *)imageDict;

@end
