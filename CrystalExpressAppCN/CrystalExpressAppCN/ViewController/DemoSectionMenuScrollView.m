//
//  DemoSectionMenuScrollView.m
//  crystalexpress
//
//  Created by roylo on 2015/3/26.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "DemoSectionMenuScrollView.h"
#import "LayoutUtils.h"

@interface DemoSectionMenuScrollView ()
@property (nonatomic, strong) NSMutableArray *itemBtns;
@property (nonatomic, strong) UIView *highlightBarView;
@property (nonatomic, assign) float itemBtnWidth;
@property (nonatomic, assign) CGRect oriFrame;
@end

@implementation DemoSectionMenuScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        [self setBackgroundColor:[UIColor whiteColor]];
        _itemBtnWidth = [LayoutUtils getScaleWidth:160];
        _oriFrame = frame;
    }
    return self;
}

- (void)createMenuItemsWithTitles:(NSArray *)titles
{
    _itemBtns = [[NSMutableArray alloc] init];
    
    float highlightBarHeight = [LayoutUtils getRelatedHeightWithOriWidth:160 OriHeight:4];
    _highlightBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - [LayoutUtils getScaleHeight:2] - highlightBarHeight, [LayoutUtils getScaleWidth:160], highlightBarHeight)];
    [_highlightBarView setBackgroundColor:[UIColor colorWithRed:234.0f/255 green:90.0f/255 blue:49.0f/255 alpha:1.0]];
    [self addSubview:_highlightBarView];
    
    for (NSString *title in titles) {
        NSUInteger index = [titles indexOfObject:title];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:234.0f/255 green:90.0f/255 blue:49.0f/255 alpha:1.0] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithWhite:0.705 alpha:1.0] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor clearColor]];
        [[button titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:[LayoutUtils getScaleHeight:34]]];
        [button setFrame:CGRectMake(index * _itemBtnWidth, 0, _itemBtnWidth, self.bounds.size.height)];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button addTarget:self action:@selector(didSelectItem:) forControlEvents:UIControlEventTouchDown]; //UIControlEventTouchUpInside
        //        button.layer.borderWidth = 1.0f;
        [_itemBtns addObject:button];
        [self addSubview:button];
    }
    [self setContentSize:CGSizeMake(_itemBtnWidth * [titles count], self.bounds.size.height)];
    
    [self updateHighlightBtnWithIndex:0];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.862 alpha:1.0].CGColor;
    bottomBorder.frame = CGRectMake(0, self.bounds.size.height - [LayoutUtils getScaleHeight:2], self.contentSize.width, [LayoutUtils getScaleHeight:2]);
    [self.layer addSublayer:bottomBorder];
}

- (void)layoutSubviews
{
    [self setFrame:_oriFrame];
}

- (void)scrollTo:(CGFloat)scrollOffset WithAnimation:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _highlightBarView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, scrollOffset * _itemBtnWidth, 0);
        
        CGFloat indicatorOffSet = scrollOffset * _itemBtnWidth;
        CGFloat center = (self.frame.size.width - _itemBtnWidth) / 2 ;
        if(indicatorOffSet > center){
            CGFloat offSet = indicatorOffSet - center;
            if (offSet > (self.contentSize.width - self.frame.size.width)) {
                offSet = self.contentSize.width - self.frame.size.width;
            }
            
            if (animated) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.contentOffset = (CGPoint){offSet};
                }];
            } else {
                [self setContentOffset:(CGPoint){offSet} animated:NO];
            }
        } else {
            if (animated) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.contentOffset = (CGPoint){0,0};
                }];
            } else {
                [self setContentOffset:(CGPoint){0,0} animated:NO];
            }
            
        }
    });
    
}

- (void)updateHighlightBtnWithIndex:(NSUInteger)index
{
    for (UIButton *btn in _itemBtns) {
        if (index == [_itemBtns indexOfObject:btn]) {
            [btn setSelected:YES];
        } else {
            [btn setSelected:NO];
        }
    }
}

#pragma mark - private method
- (void)didSelectItem:(id)sender
{
    if ([sender isMemberOfClass:[UIButton class]] == NO) {
        return;
    }
    
    UIButton *curBtn = (UIButton *)sender;
    NSUInteger index = [_itemBtns indexOfObject:curBtn];
  
    [self scrollTo:index WithAnimation:YES];
    [self updateHighlightBtnWithIndex:index];

    if ([[self delegate] respondsToSelector:@selector(selectItemAt:)])
        [[self delegate] selectItemAt:index];
}
@end
