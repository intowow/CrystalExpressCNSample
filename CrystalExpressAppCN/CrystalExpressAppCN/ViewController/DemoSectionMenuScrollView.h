//
//  DemoSectionMenuScrollView.h
//  crystalexpress
//
//  Created by roylo on 2015/3/26.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DemoSectionMenuDelegate <UIScrollViewDelegate>

@optional
- (void)selectItemAt:(NSUInteger)index;
@end

@interface DemoSectionMenuScrollView : UIScrollView
@property (nonatomic, weak) id<DemoSectionMenuDelegate> delegate;

- (void)createMenuItemsWithTitles:(NSArray *)titles;
- (void)scrollTo:(CGFloat)scrollOffset WithAnimation:(BOOL)animated;
- (void)updateHighlightBtnWithIndex:(NSUInteger)index;
@end
