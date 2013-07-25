//
//  DetailScrollViewController.h
//  swiping
//
//  Created by amayoral on 23/07/13.
//  Copyright (c) 2013 amayoral. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NessScrollView;

@interface DetailScrollViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    int cardId;
}

@property (nonatomic, readwrite) int openCamera;
@property (nonatomic, readwrite) int selectedCardPicture;

@property (nonatomic, readwrite) int cardId;
@property (nonatomic, retain) IBOutlet UIPageControl *customPageControl;
@property (nonatomic, retain) IBOutlet NessScrollView *ownScrollView;
@property (nonatomic, retain) NSMutableArray *itemsOfView;

- (IBAction)backBtn:(id)sender;
- (IBAction)takePictureBtn:(id)sender;

@end
