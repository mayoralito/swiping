//
//  NessScrollView.m
//  swiping
//
//  Created by amayoral on 24/07/13.
//  Copyright (c) 2013 amayoral. All rights reserved.
//

#import "NessScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NessScrollView

@synthesize nofiticationName, defaultPage, currentPage, firstPage, lastPage, totalPages, parentPage;
@synthesize rectValues, defaultOffset, viewOffsetPoint, tagBase, tagBaseImage, percentSmaller;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//
// UIScrollView behavior
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

//
// Create a custom configuration for UIScrollView behavior
- (id)configScrollView
{
    [self setDelegate:self];
    //[self setBackgroundColor:[UIColor purpleColor]];
    
    ////////////////////////////////////////
    // Custom configuration for UIScrollView
    ////////////////////////////////////////
    [self setPagingEnabled:YES];
    [self setScrollEnabled:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    
    
    ////////////////////////////////////////
    // Init iVars
    ////////////////////////////////////////
    self.nofiticationName    = @"";
    self.defaultPage         = 0.0f;
    self.currentPage         = 0.0f;
    self.firstPage           = 0.0f;
    self.lastPage            = 0.0f;
    self.totalPages          = 0.0f;
    
    self.defaultOffset       = CGPointMake(0, 0);
    self.viewOffsetPoint     = CGPointMake(100, 0);
    self.rectValues          = [[NSMutableArray alloc] init];
    
    self.tagBase             = 100.0f;
    self.tagBaseImage        = 500.0f;
    self.percentSmaller      = 0.9f;
    
    _swipeLimit              = 95.0f;
    
    return self;
}

//
// UIScrollView behavior: Add elements to component
- (void)addElements:(NSArray *)arrayWithViews
{
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    for(UIView *view in [self subviews]){
        [view removeFromSuperview];
    }
    
    ////////////////////////////////////////////
    // iVars
    ////////////////////////////////////////////
    int totalOfItemsPage    = [arrayWithViews count];
    CGFloat posx            = 0.0f;
    CGFloat posy            = 0.0f;
    CGFloat ewidth          = self.frame.size.width;
    CGFloat eheight         = self.frame.size.height;
    
    for (int i=0; i<totalOfItemsPage; i++)
    {
        posx = i*ewidth;
        ////////////////////////////////////////////
        // Main View
        ////////////////////////////////////////////
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [contentView setTag:self.tagBase+i];
        
        contentView.layer.cornerRadius = 7;
        [contentView setBackgroundColor:[UIColor clearColor]];
        
        ////////////////////////////////////////////////
        // Create and Add Image to UIView
        ////////////////////////////////////////////////
        UIImage *currentImage = [UIImage imageNamed:[arrayWithViews objectAtIndex:i]];
        //[contentView setBackgroundColor:[UIColor colorWithPatternImage:currentImage]];
        
        /*
        if(i==0){
            [contentView setBackgroundColor:[UIColor greenColor]];            
        }else if(i==(totalOfItemsPage-1)){
            [contentView setBackgroundColor:[UIColor blueColor]];
        }else{
            [contentView setBackgroundColor:[UIColor redColor]];
        }
        */
        [contentView setFrame:CGRectMake(posx + (self.viewOffsetPoint.x/2),
                                         posy,
                                         ewidth - self.viewOffsetPoint.x,
                                         eheight
                                         )];
        
        
        [self.rectValues addObject:[NSValue valueWithCGRect:contentView.frame]];
        
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:currentImage];
        [backgroundImage setFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
        backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
        [backgroundImage setTag:self.tagBaseImage+i];
        // Add image to view
        [contentView addSubview:backgroundImage];
        
        ////////////////////////////////////////////////
        // Add Gesture Recognizer to View
        ////////////////////////////////////////////////
        UITapGestureRecognizer *tapAction=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openDetail:)];
        [tapAction setNumberOfTapsRequired:1];
        
        [contentView setUserInteractionEnabled:YES];
        [contentView setMultipleTouchEnabled:NO];
        [contentView addGestureRecognizer:tapAction];
        
        UIPanGestureRecognizer *ownGestRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        [contentView addGestureRecognizer:ownGestRecog];
        
        [self addSubview:contentView];
        
    }
    
    if(self.defaultPage>=(totalOfItemsPage-1)){
        self.defaultPage = (totalOfItemsPage-1);
    }
    
    if(self.defaultPage<0){
        self.defaultPage = 0;
    }
    
    self.currentPage = self.defaultPage;
    
    ////////////////////////////////////////////////
    // Range available (width, height)
    ////////////////////////////////////////////////
    CGFloat widthAva = self.frame.size.width * totalOfItemsPage;
    [self setContentSize: CGSizeMake(widthAva, self.frame.size.height) ];
    
    ////////////////////////////////////////////////
    // Position page
    ////////////////////////////////////////////////
    CGFloat toDefaultPage = self.frame.size.width*self.defaultPage;
    if(toDefaultPage>=widthAva-self.frame.size.width){
        toDefaultPage = widthAva-self.frame.size.width;
    }
    
    [self setContentOffset:CGPointMake(toDefaultPage, 0) animated:NO ];
    [self setTotalPages:totalOfItemsPage];
    
    self.defaultOffset = self.contentOffset;
    
    [self reDrawUIComponents];
    [self effectSmallerSideElements];
    
}

- (id)reDrawUIComponents
{
    
    ////////////////////////////////////////////////
    // Put visible elements 
    ////////////////////////////////////////////////
    if(self.currentPage==0){
        CGRect currentFrame = [[self.rectValues objectAtIndex:self.currentPage] CGRectValue];
        CGRect nextFrame = [[self.rectValues objectAtIndex:self.currentPage+1] CGRectValue];
        
        UIView *currentView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage];
        [currentView setFrame:currentFrame];
        
        UIView *nextView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage + 1];
        [nextView setFrame:CGRectMake(nextFrame.origin.x - (self.viewOffsetPoint.x/1.5), nextFrame.origin.y, nextFrame.size.width, nextFrame.size.height)];
        
    }else if(self.currentPage!=0 && self.currentPage!=(self.totalPages-1) ){
        CGRect currentFrame = [[self.rectValues objectAtIndex:self.currentPage] CGRectValue];
        CGRect lastFrame = [[self.rectValues objectAtIndex:self.currentPage-1] CGRectValue];
        CGRect nextFrame = [[self.rectValues objectAtIndex:self.currentPage+1] CGRectValue];
        
        UIView *currentView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage];
        [currentView setFrame:currentFrame];
        
        UIView *nextView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage + 1];
        [nextView setFrame:CGRectMake(nextFrame.origin.x - (self.viewOffsetPoint.x/1.5), nextFrame.origin.y, nextFrame.size.width, nextFrame.size.height)];
        
        UIView *lastView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage - 1];
        [lastView setFrame:CGRectMake(lastFrame.origin.x + (self.viewOffsetPoint.x/1.5), lastFrame.origin.y, lastFrame.size.width, lastFrame.size.height)];
    }else{
        CGRect currentFrame = [[self.rectValues objectAtIndex:self.currentPage] CGRectValue];
        CGRect lastFrame = [[self.rectValues objectAtIndex:self.currentPage-1] CGRectValue];
        
        UIView *currentView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage];
        [currentView setFrame:currentFrame];
        
        UIView *lastView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage - 1];
        [lastView setFrame:CGRectMake(lastFrame.origin.x + (self.viewOffsetPoint.x/1.5), lastFrame.origin.y, lastFrame.size.width, lastFrame.size.height)];
    }
    
    return self;
}

- (id)effectSmallerSideElements
{
    ////////////////////////////////////////////////
    // Only update side elements
    ////////////////////////////////////////////////
    CGFloat initY;
    
    UIView *currentView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage];
    [currentView setFrame:CGRectMake(currentView.frame.origin.x, currentView.frame.origin.y, currentView.frame.size.width, currentView.frame.size.height)];
    
    if(self.currentPage==0){
        UIView *nextView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage + 1];
        initY = (self.frame.size.height - (nextView.frame.size.height * self.percentSmaller))/2;
        [nextView setFrame:CGRectMake(nextView.frame.origin.x, initY, nextView.frame.size.width, nextView.frame.size.height * self.percentSmaller)];        
    }else if(self.currentPage!=0 && self.currentPage!=(self.totalPages-1) ){
        UIView *nextView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage + 1];
        initY = (self.frame.size.height - (nextView.frame.size.height * self.percentSmaller))/2;
        [nextView setFrame:CGRectMake(nextView.frame.origin.x, initY, nextView.frame.size.width, nextView.frame.size.height * self.percentSmaller)];
        
        UIView *lastView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage - 1];
        initY = (self.frame.size.height - (lastView.frame.size.height * self.percentSmaller))/2;
        [lastView setFrame:CGRectMake(lastView.frame.origin.x, initY, lastView.frame.size.width, lastView.frame.size.height * self.percentSmaller)];
    }else{
        UIView *lastView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage - 1];
        initY = (self.frame.size.height - (lastView.frame.size.height * self.percentSmaller))/2;
        [lastView setFrame:CGRectMake(lastView.frame.origin.x, initY, lastView.frame.size.width, lastView.frame.size.height * self.percentSmaller)];
    }
    
    return self;
}

- (id)animateSideElements : (NSString *)direction
{
    //NSLog(@"%f %f %f %f", nextView.frame.origin.x, nextView.frame.origin.y, nextView.frame.size.width, nextView.frame.size.height);
    
    if(self.currentPage==0){
        UIView *nextView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage + 1];
        CGPoint newCoords = [self returNewPositionOnUpdateRight:nextView withDirection:direction];
        [nextView setFrame:CGRectMake(nextView.frame.origin.x, newCoords.x, nextView.frame.size.width, newCoords.y)];
    }else if(self.currentPage!=0 && self.currentPage!=(self.totalPages-1) ){
        UIView *nextView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage + 1];
        CGPoint newCoordsRight = [self returNewPositionOnUpdateMiddRight:nextView withDirection:direction];
        [nextView setFrame:CGRectMake(nextView.frame.origin.x, newCoordsRight.x, nextView.frame.size.width, newCoordsRight.y)];
        
        UIView *lastView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage - 1];
        CGPoint newCoordsLeft = [self returNewPositionOnUpdateMiddleLeft:lastView withDirection:direction];
        [lastView setFrame:CGRectMake(lastView.frame.origin.x, newCoordsLeft.x, lastView.frame.size.width, newCoordsLeft.y)];
    }else{
        UIView *lastView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage - 1];
        CGPoint newCoords = [self returNewPositionOnUpdateLeft:lastView withDirection:direction];
        [lastView setFrame:CGRectMake(lastView.frame.origin.x, newCoords.x, lastView.frame.size.width, newCoords.y)];
    }
    
    return self;
}

//
// Where [Point.x = position Y] and [Point.y = width] of view
- (CGPoint)returNewPositionOnUpdateMiddleLeft : (UIView *)nextView withDirection : (NSString *)direction
{
    if(_posYRedrawL==0){
        _posYRedrawL = nextView.frame.origin.y;
    }
    if(_posHRedrawL==0){
        _posHRedrawL = nextView.frame.size.height;
    }
    
    if([direction isEqualToString:@"right"]){
        if(self.frame.size.height>=_posHRedrawL){
            _posYRedrawL -= 0.2;
            _posHRedrawL += 0.4;
        }
    }else{
        if(nextView.frame.origin.y>=_posYRedrawL){
            _posYRedrawL += 0.2;
            _posHRedrawL -= 0.4;
        }
    }
    
    return CGPointMake(_posYRedrawL, _posHRedrawL);
}

- (CGPoint)returNewPositionOnUpdateMiddRight : (UIView *)nextView withDirection : (NSString *)direction
{
    if(_posYRedrawR==0){
        _posYRedrawR = nextView.frame.origin.y;
    }
    if(_posHRedrawR==0){
        _posHRedrawR = nextView.frame.size.height;
    }
    
    if([direction isEqualToString:@"left"]){
        if(self.frame.size.height>=_posHRedrawR){
            _posYRedrawR -= 0.2;
            _posHRedrawR += 0.4;
        }
    }else{
        if(nextView.frame.origin.y>=_posYRedrawR){
            _posYRedrawR += 0.2;
            _posHRedrawR -= 0.4;
        }
    }
    
    return CGPointMake(_posYRedrawR, _posHRedrawR);
}

//
// Where [Point.x = position Y] and [Point.y = width] of view
- (CGPoint)returNewPositionOnUpdateRight : (UIView *)nextView withDirection : (NSString *)direction
{
    if(_posYRedraw==0){
        _posYRedraw = nextView.frame.origin.y;
    }
    if(_posHRedraw==0){
        _posHRedraw = nextView.frame.size.height;
    }
    
    if([direction isEqualToString:@"left"]){
        if(self.frame.size.height>=_posHRedraw){
            _posYRedraw -= 0.2;
            _posHRedraw += 0.4;
        }
    }else{
        if(nextView.frame.origin.y>=_posYRedraw){
            _posYRedraw += 0.2;
            _posHRedraw -= 0.4;
        }
    }
    
    return CGPointMake(_posYRedraw, _posHRedraw);
}

//
// Where [Point.x = position Y] and [Point.y = width] of view
- (CGPoint)returNewPositionOnUpdateLeft : (UIView *)nextView withDirection : (NSString *)direction
{
    if(_posYRedraw==0){
        _posYRedraw = nextView.frame.origin.y;
    }
    if(_posHRedraw==0){
        _posHRedraw = nextView.frame.size.height;
    }
    
    if([direction isEqualToString:@"right"]){
        if(self.frame.size.height>=_posHRedraw){
            _posYRedraw -= 0.2;
            _posHRedraw += 0.4;
        }
    }else{
        if(nextView.frame.origin.y>=_posYRedraw){
            _posYRedraw += 0.2;
            _posHRedraw -= 0.4;
        }
    }
    
    return CGPointMake(_posYRedraw, _posHRedraw);
}

#pragma mark - Gesture swipe actions
// This is my gesture recognizer handler, which detects movement in a particular
// direction, conceptually tells a camera to start moving in that direction
// and when the user lifts their finger off the screen, tells the camera to stop.

- (void)handleSwipe:(UIPanGestureRecognizer *)gesture
{
    
    CGPoint velocity = [gesture velocityInView:self];
    CGPoint translation = [gesture translationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        //NSLog(@"Began : translation: %f %f - current Page: %f ", translation.x, translation.y, self.currentPage);
        _offsetCounterPerScroll = 0.0f;
        _counterControl = 0;
        _beginAnimation = NO;
        _strDirection = @"";
        _strPosition = @"";
        _posYRedraw = 0.0f;
        _posHRedraw = 0.0f;
        
        _posYRedrawL = 0.0f;
        _posHRedrawL = 0.0f;
        
        _posYRedrawR = 0.0f;
        _posHRedrawR = 0.0f;
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged )
    {
        
        if(true)
        {
            
            ///////////////////////////////////////
            // Effect to MOVE offset
            ///////////////////////////////////////
            
            [self setContentOffset:[self getPointOfPage:self.currentPage withOffset:translation.x] animated:NO ];
            [self reDrawUIComponents];
            [self effectSmallerSideElements];
            
            
            ///////////////////////////////////////
            // Effects animation (GrowUp)
            ///////////////////////////////////////
            if(velocity.x > 0)
            {
                if(self.currentPage>0){
                    //NSLog(@"gesture went right");
                    
                }
                
                // Always call to reduce next element
                [self animateSideElements:@"right"];
                
            }
            else
            {
                if(self.currentPage<self.totalPages-1){
                    //NSLog(@"gesture went left");
                    
                }
                
                [self animateSideElements:@"left"];
                
            }
            
            
            
            // Add growup effect
            
        }
        
        if(false)
        {
            if (velocity.y >0)   // panning down
            {
                //self.brightness = self.brightness -.02;
                //NSLog (@"gesture went down");
            }
            else                // panning up
            {
                //self.brightness = self.brightness +.02;
                //NSLog (@"gesture went up");
            }
        }
        
        
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        
        //NSLog(@"swiping END!!! %i", gesture.state);
        
        if(translation.x<0) translation.x*=-1;
        if(translation.x >= _swipeLimit){
            
            if(velocity.x > 0)
            {
                //NSLog(@"gesture from left to right");
                self.currentPage --;
                if(self.currentPage<self.firstPage){
                    self.currentPage = self.firstPage;
                }
                
                [self.parentPage setCurrentPage:self.currentPage];
            }
            else
            {
                //NSLog(@"gesture from right to left");
                self.currentPage++;
                if(self.currentPage>self.totalPages-1){
                    self.currentPage = self.totalPages-1;
                }
                
                [self.parentPage setCurrentPage:self.currentPage];
            }            
        }
        
        [self setContentOffset:[self getPointOfPage:self.currentPage] animated:YES ];
        [self reDrawUIComponents];
        [self effectSmallerSideElements];
        
        //NSLog(@"data: %@", [self.rectValues objectAtIndex:self.currentPage]);
    }
    
}

- (id)applyAnimation: (CGPoint)translation
{
    if(translation.x<0) translation.x*=-1;
    NSLog(@"end translation.x: %f", translation.x);
    if(translation.x >= _swipeLimit){
        [self setContentOffset:[self getPointOfPage:self.currentPage] animated:YES ];
        [self reDrawUIComponents];
        [self effectSmallerSideElements];
    }else{
        /*
        if(self.currentPage < self.firstPage){
            self.currentPage = self.firstPage;
        }*/
        NSLog(@"NO swipe! + %f",self.currentPage );
        [self setContentOffset:[self getPointOfPage:self.currentPage] animated:YES ];
    }
    
    return self;
}

//
// Get position of Point of current page
-(CGPoint )getPointOfPage : (CGFloat)paging
{
    
    ////////////////////////////////////////////////
    // Position page
    ////////////////////////////////////////////////
    CGFloat widthAva = self.frame.size.width * self.totalPages;
    CGFloat toDefaultPage = self.frame.size.width*paging;
    if(toDefaultPage>=widthAva-self.frame.size.width){
        toDefaultPage = widthAva-self.frame.size.width;
    }
    
    //NSLog(@"to this data [%f]: %f", self.currentPage, toDefaultPage);
    
    return CGPointMake(toDefaultPage, self.defaultOffset.y);
}

//
// Get position of Point of current page
-(CGPoint )getPointOfPage : (CGFloat)paging withOffset : (CGFloat)offset
{
    
    ////////////////////////////////////////////////
    // Position page
    ////////////////////////////////////////////////
    CGFloat widthAva = self.frame.size.width * self.totalPages;
    CGFloat toDefaultPage = self.frame.size.width*paging;
    if(toDefaultPage>=widthAva-self.frame.size.width){
        toDefaultPage = widthAva-self.frame.size.width;
    }
    
    //NSLog(@"%f %f %f", offset, self.defaultOffset.x, _offsetCounterPerScroll);
    
    return CGPointMake(toDefaultPage - offset, self.defaultOffset.y);
}

#pragma mark - Actions to elements
-(void)openDetail:(UITapGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        UIImageView *xtrail_view    =   (UIImageView*)sender.view;
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:xtrail_view.tag],
                              @"info", // LLave del dictionario
                              nil
                              ];
        if(true)
        [[NSNotificationCenter defaultCenter] postNotificationName:nofiticationName object:self userInfo:dict];
    }
}

#pragma mark - Delegate stuffs fro UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    //self.defaultOffset = scrollView.contentOffset;
    
    //[self reDrawUIComponents];
    //[self effectSmallerSideElements];
    
    return;
    
    
    
    if(_counterControl<scrollView.contentOffset.x){
        //NSLog(@"swipe left");
        if(self.currentPage==0){
            //NSLog(@"swipe left on first element");
            
            _beginAnimation = YES;
            _strDirection = @"left";
            _strPosition = @"first";
            
            
        }else if(self.currentPage!=0 && self.currentPage!=(self.totalPages-1) ){
            //NSLog(@"swipe left middle element");
            
            _beginAnimation = YES;
            _strDirection = @"left";
            _strPosition = @"middle";
            
        }else{
            //NSLog(@"swipe left on last element");
            // Do Nothing!
            //NSLog(@"// Do Nothing!");
        }
    }else{
        //NSLog(@"swipe right");
        if(self.currentPage==0){
            //NSLog(@"swipe right on first element");
            // Do Nothing!
            //NSLog(@"// Do Nothing!");
        }else if(self.currentPage!=0 && self.currentPage!=(self.totalPages-1) ){
            //NSLog(@"swipe right middle element");
            
            _beginAnimation = YES;
            _strDirection = @"right";
            _strPosition = @"middle";
            
        }else{
            //NSLog(@"swipe right on last element");
            
            _beginAnimation = YES;
            _strDirection = @"right";
            _strPosition = @"last";
            
        }
    }
    
    
    if(_beginAnimation==YES){
        //NSLog(@"ANIMATION WITH: In page: %f, %f, %f, %f", scrollView.frame.size.width, scrollView.contentOffset.x, self.currentPage, scrollView.frame.origin.x);
        [self addEffectGrowUpForPage:scrollView direction:_strDirection position:_strPosition];
    }
    
    _counterControl = scrollView.contentOffset.x;
    _offsetCounterPerScroll ++;
}

- (id)addEffectGrowUpForPage:(UIScrollView *)scrollView direction : (NSString *)scrollDirection position : (NSString *)inPosition
{
    
    int targetGrowUp = self.currentPage;
    UIView *nextView = (UIView*)[self viewWithTag:self.tagBase + targetGrowUp];
    
    if(scrollView.contentOffset.x >= scrollView.frame.size.width*self.currentPage && [scrollDirection isEqualToString:@"left"]){
        
        if([inPosition isEqualToString:@"first"]){
            //NSLog(@"LEFT-FIRST: In page: %f, %f, %f, %f", scrollView.frame.size.width, scrollView.contentOffset.x, self.currentPage, scrollView.frame.origin.x);
            
            float increasePercent = 1.0f - self.percentSmaller;
            float targetPercent = nextView.frame.origin.y;
            NSLog(@"original: %f inc: %f ", targetPercent, increasePercent);
            
            CGFloat initY = (self.frame.size.height - (nextView.frame.size.height * self.percentSmaller))/2;
            NSLog(@"test: %f", initY);
            
            //[nextView setFrame:CGRectMake(nextView.frame.origin.x, initY, nextView.frame.size.width, nextView.frame.size.height * self.percentSmaller)];
            
        }else if([inPosition isEqualToString:@"middle"]){
            //NSLog(@"LEFT-MIDDLE: In page: %f, %f, %f, %f", scrollView.frame.size.width, scrollView.contentOffset.x, self.currentPage, scrollView.frame.origin.x);
            
        }
        
    }
    
    if(scrollView.contentOffset.x < scrollView.frame.size.width*self.currentPage && [scrollDirection isEqualToString:@"right"]){
        
        if([inPosition isEqualToString:@"last"]){
            //NSLog(@"RIGHT-LAST: In page: %f, %f, %f, %f", scrollView.frame.size.width, scrollView.contentOffset.x, self.currentPage, scrollView.frame.origin.x);
            
        }else if([inPosition isEqualToString:@"middle"]){
            //NSLog(@"RIGHT-MIDDLE: In page: %f, %f, %f, %f", scrollView.frame.size.width, scrollView.contentOffset.x, self.currentPage, scrollView.frame.origin.x);
            
        }
    }
    
    
    if([scrollDirection isEqualToString:@"left"] && scrollView.contentOffset.x >= scrollView.frame.size.width*self.currentPage){
        /*
        CGRect currentFrame = [[self.rectValues objectAtIndex:self.currentPage] CGRectValue];
        CGRect nextFrame = [[self.rectValues objectAtIndex:self.currentPage+1] CGRectValue];
        
        UIView *currentView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage];
        [currentView setFrame:currentFrame];
        
        UIView *nextView = (UIView*)[self viewWithTag:self.tagBase + self.currentPage + 1];
        [nextView setFrame:CGRectMake(nextFrame.origin.x - (self.viewOffsetPoint.x/1.5), nextFrame.origin.y, nextFrame.size.width, nextFrame.size.height)];
        */
        
        NSLog(@"left - drawing! - %f %f asdasd %f", _counterControl, scrollView.contentOffset.x, (scrollView.contentOffset.x-_counterControl));
        //[self setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO ];
        
    }else{
        
    }
    
    
    
    return  self;
}

@end