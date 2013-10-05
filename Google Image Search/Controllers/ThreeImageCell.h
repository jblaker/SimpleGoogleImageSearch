//
//  ThreeImageCell.h
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreeImageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageViewLeft;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewCenter;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewRight;
@property (nonatomic, strong) NSArray *imageDicts;

- (void)loadImages;

@end
