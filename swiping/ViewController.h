//
//  ViewController.h
//  swiping
//
//  Created by amayoral on 23/07/13.
//  Copyright (c) 2013 amayoral. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NessScrollView;

@interface ViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIPageControl *customPageControl;
@property (nonatomic, retain) IBOutlet NessScrollView *ownScrollView;
@property (nonatomic, retain) NSMutableArray *itemsOfView;

- (IBAction)openDetail:(id)sender;


@end
