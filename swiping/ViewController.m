//
//  ViewController.m
//  swiping
//
//  Created by amayoral on 23/07/13.
//  Copyright (c) 2013 amayoral. All rights reserved.
//

#import "ViewController.h"
#import "DetailScrollViewController.h"

#import "NessScrollView.h"

@interface ViewController (){
    int originalTouch;
    BOOL suspendScroll;
}

@end

@implementation ViewController

@synthesize ownScrollView, customPageControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _itemsOfView = [[NSMutableArray alloc] init];
    
    // Load content
    for(int i=0; i<3; i++){
        [_itemsOfView addObject:[NSString stringWithFormat:@"%i.png", (i+1)]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapItem:) name:@"onTapItem" object:nil];
    
    // Load view with contento
    [self loadScrollViewContent];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //
}

- (IBAction)openDetail:(id)sender
{
    [self performSegueWithIdentifier:@"goDetail" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goDetail"])
	{
        // Primer UINavigationController
        UINavigationController *navitagionController = (UINavigationController*)segue.destinationViewController;
        DetailScrollViewController *detailScrollViewController = (DetailScrollViewController*)[[navitagionController viewControllers] objectAtIndex:0];
        
        if([sender tag]<1) [sender setTag:1];
        [detailScrollViewController setCardId:[sender tag]];
        
	}
    else
    {
        NSLog(@"MAIN:-> segue.identifier: %@", segue.identifier);
    }
    
}

- (void)loadScrollViewContent
{
    suspendScroll = NO;
    
    [ownScrollView configScrollView];
    [ownScrollView setNofiticationName:@"onTapItem"];
    [ownScrollView setDefaultPage:0];
    [ownScrollView addElements: _itemsOfView];
    
    [customPageControl setNumberOfPages:ownScrollView.totalPages];
    [customPageControl setCurrentPage:ownScrollView.currentPage];
    
    [ownScrollView setParentPage:customPageControl];
}

- (IBAction)changePage:(id)sender
{
    //NSLog(@"changePage");
    int page = ((UIPageControl *)sender).currentPage;
    CGRect frame = ownScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [ownScrollView scrollRectToVisible:frame animated:YES];
    
    //[nassScrollView scrollViewDidCoolUI:page];
}

#pragma mark - NSNotifications
- (void)onTapItem:(NSNotification *)notification
{
    
    NSNumber *indexToGo = (NSNumber*)[notification.userInfo objectForKey:@"info"];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTag:[indexToGo intValue]];
    [self openDetail:button];
    
}

@end
