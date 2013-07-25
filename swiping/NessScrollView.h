//
//  NessScrollView.h
//  swiping
//
//  Created by amayoral on 24/07/13.
//  Copyright (c) 2013 amayoral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NessScrollView : UIScrollView <UIScrollViewDelegate>
{
    NSString        *nofiticationName;
    NSMutableArray  *rectValues;
    
    CGFloat defaulPage;
    CGFloat currentPage;
    CGFloat firstPage;
    CGFloat lastPage;
    CGFloat totalPages;
    
    CGPoint defaultOffset;
    CGPoint viewOffsetPoint;
    
    CGFloat tagBase;
    CGFloat tagBaseImage;
    CGFloat percentSmaller;
    
    UIPageControl *parentPage;
}


@property (nonatomic, readwrite)    CGFloat posYRedraw;
@property (nonatomic, readwrite)    CGFloat posHRedraw;

@property (nonatomic, readwrite)    CGFloat posYRedrawR;
@property (nonatomic, readwrite)    CGFloat posHRedrawR;

@property (nonatomic, readwrite)    CGFloat posYRedrawL;
@property (nonatomic, readwrite)    CGFloat posHRedrawL;

@property (nonatomic, readwrite)    CGFloat swipeLimit;
@property (nonatomic, readwrite)    CGFloat counterControl;
@property (nonatomic, readwrite)    CGFloat offsetCounterPerScroll;
@property (nonatomic, readwrite)    BOOL beginAnimation;
@property (nonatomic, retain)       NSString *strDirection;
@property (nonatomic, retain)       NSString *strPosition;

@property (nonatomic, retain)       NSString *nofiticationName;
@property (nonatomic, retain)       NSMutableArray *rectValues;

@property (nonatomic, readwrite)    CGFloat defaultPage;
@property (nonatomic, readwrite)    CGFloat currentPage;
@property (nonatomic, readwrite)    CGFloat firstPage;
@property (nonatomic, readwrite)    CGFloat lastPage;
@property (nonatomic, readwrite)    CGFloat totalPages;

@property (nonatomic, readwrite)    CGPoint defaultOffset;
@property (nonatomic, readwrite)    CGPoint viewOffsetPoint;

@property (nonatomic, readwrite)    CGFloat tagBase;
@property (nonatomic, readwrite)    CGFloat tagBaseImage;
@property (nonatomic, readwrite)    CGFloat percentSmaller;

@property (nonatomic, retain)       UIPageControl *parentPage;

- (id)configScrollView;
- (id)scrollToPageAtIndex : (NSInteger) index animated : (BOOL) animated;
- (void)addElements:(NSArray *)arrayWithViews;

@end
