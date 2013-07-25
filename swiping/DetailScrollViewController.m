//
//  DetailScrollViewController.m
//  swiping
//
//  Created by amayoral on 23/07/13.
//  Copyright (c) 2013 amayoral. All rights reserved.
//

#import "DetailScrollViewController.h"

#import "NessScrollView.h"

@interface DetailScrollViewController (){
    int originalTouch;
    BOOL suspendScroll;
}

@end

@implementation DetailScrollViewController

@synthesize ownScrollView, customPageControl;

@synthesize cardId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setTitle:[NSString stringWithFormat:@"Prev Card tag: %i", cardId]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _openCamera = 0;
    _itemsOfView = [[NSMutableArray alloc] init];
    
    // Load content
    for(int i=0; i<3; i++){
        [_itemsOfView addObject:[NSString stringWithFormat:@"%i.png", (i+1)]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapOpenCamera:) name:@"onTapItemDetail" object:nil];
    
    // Load view with contento
    [self loadScrollViewContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePictureBtn:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        
        // Has camera
        
        if(_openCamera == 0){
            //NSLog(@"Open Camera: %i", [sender tag]);
            
            _selectedCardPicture = (int)[sender tag];
            
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [picker setDelegate:self];
            
            [self presentViewController:picker animated:YES completion:nil];
        }
        _openCamera = 1;
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Camera not detected."
                                                       delegate:self
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles: nil];
        [alert show];
    }

        
    
    
}

#pragma mark - When finish shoot

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage* image = [info objectForKey: UIImagePickerControllerOriginalImage];
    // Do stuff to image.
    
    if(nil != image )
    {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:^(void){
        if(nil != image ){
            UIImageView *bgImage = (UIImageView *)[ownScrollView viewWithTag:(_selectedCardPicture+400)];
            [bgImage setImage:image];
        }
        
    }];
}

-(void)imagePickerController1:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSLog(@"didFinishPickingMediaWithInfo");
    
    // Get image from camera
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if(nil != image )
    {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    
    
    //NSDictionary *infoToObject = [NSDictionary dictionaryWithObjectsAndKeys:image, @"uiimage", nil];
    
    // Launch notificaion center
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PREVIEW_PICTURE" object:nil userInfo:infoToObject];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"Some error: %@", error);
}

- (void)loadScrollViewContent
{
    suspendScroll = NO;
    
    [ownScrollView configScrollView];
    [ownScrollView setNofiticationName:@"onTapItemDetail"];
    [ownScrollView setDefaultPage:1];
    [ownScrollView addElements: _itemsOfView];
    
    [customPageControl setNumberOfPages:ownScrollView.totalPages];
    [customPageControl setCurrentPage:ownScrollView.currentPage];
    
    [ownScrollView setParentPage:customPageControl];
}

#pragma mark - NSNotifications
- (void)onTapOpenCamera:(NSNotification *)notification
{
    
    NSNumber *indexToGo = (NSNumber*)[notification.userInfo objectForKey:@"info"];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTag:[indexToGo intValue]];
    [self takePictureBtn:button];
    
}

@end
