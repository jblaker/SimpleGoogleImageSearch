//
//  ImageSearchViewController.h
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

@class ImageRequestManager;

@interface ImageSearchViewController : PSUICollectionViewController<UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) ImageRequestManager *imageRequestManager;

- (void)doSearchWithString:(NSString *)queryString;
- (void)requestMoreImages;

@end
