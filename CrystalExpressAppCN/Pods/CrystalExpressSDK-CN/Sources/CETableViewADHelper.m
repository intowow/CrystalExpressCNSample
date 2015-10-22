//
//  CETableViewADHelper.m
//  Pods
//
//  Created by roylo on 2015/7/16.
//
//

#import "CETableViewADHelper.h"
#import "CEStreamPlacementADHelper.h"
#import "CEStreamTagADHelper.h"
#import "I2WAPI.h"
#import "CEAdInvocation.h"
#import <objc/runtime.h>

#define SCREEN_WIDTH (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#pragma mark - CETableViewADHelper

@interface CETableViewADHelper() <UITableViewDataSource, UITableViewDelegate, CEStreamAdHelperDelegate>
@property (nonatomic, strong) CEStreamADHelper *streamAdHelper;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<UITableViewDataSource> originalDataSource;
@property (nonatomic, weak) id<UITableViewDelegate> originalDelegate;
@property (nonatomic, assign) BOOL enableAd;
@property (nonatomic, assign) float adVerticalMargin;
@property (nonatomic, strong) UIColor *adBgColor;
@property (nonatomic, copy) void (^customizedAdCellBlock)(UITableViewCell *adCell);
@end

@implementation CETableViewADHelper
+ (instancetype)helperWithTableView:(UITableView *)tableView
                     viewController:(UIViewController *)controller
                          placement:(NSString *)placement
{
    CETableViewADHelper *helper = [[CETableViewADHelper alloc] initWithTableView:tableView viewController:controller];
    helper.streamAdHelper = [[CEStreamPlacementADHelper alloc] initWithPlacement:placement delegate:helper];
    return helper;
}

+ (instancetype)helperWithTableView:(UITableView *)tableView
                     viewController:(UIViewController *)controller
                              adTag:(NSString *)adTag
{
    CETableViewADHelper *helper = [[CETableViewADHelper alloc] initWithTableView:tableView viewController:controller];
    helper.streamAdHelper = [[CEStreamTagADHelper alloc] initWithAdTag:adTag delegate:helper];
    return helper;
}

- (instancetype)initWithTableView:(UITableView *)tableView
                   viewController:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        _tableView = tableView;
        _originalDataSource = tableView.dataSource;
        _originalDelegate = tableView.delegate;
        tableView.delegate = self;
        tableView.dataSource = self;
    
        [tableView ce_setAdHelper:self];
        _enableAd = NO;
        _adVerticalMargin = 5;
        _adBgColor = [UIColor clearColor];
        _customizedAdCellBlock = nil;
    }
    
    return self;
}

- (void)setAdWidth:(float)width
{
    [_streamAdHelper setAdWidth:width];
}

- (void)setAdVerticalMargin:(float)verticalMargin
{
    _adVerticalMargin = verticalMargin;
}

- (void)setAdBackgroundColor:(UIColor *)bgColor
{
    _adBgColor = bgColor;
}

- (void)setAdCellCustomizedBlock:(void (^)(UITableViewCell *))customizedAdCellBlock
{
    _customizedAdCellBlock = customizedAdCellBlock;
}

- (void)loadAd
{
    _enableAd = YES;
    int visibleCounts = (int)[[_tableView visibleCells] count];
    [_streamAdHelper prerollWithVisibleCounts:visibleCounts];
    [_tableView ce_reloadData];
    [self updateVisiblePositions];
}

- (void)disableAd
{
    _enableAd = NO;
    [self cleanAds];
}

- (void)cleanAds
{
    [_streamAdHelper reset];
}

- (void)onShow
{
    [_streamAdHelper setActive:YES];
}

- (void)onHide
{
    [_streamAdHelper setActive:NO];
}

- (void)setAppAdsIndexPaths:(NSArray *)appAdsIndexPaths
{
    [_streamAdHelper setAppAdsIndexPaths:appAdsIndexPaths];
}

- (void)setAdCustomIndexPaths:(NSArray *)adIndexPaths
{
    [_streamAdHelper setAdCustomIndexPaths:adIndexPaths];
}

- (void)setAutoPlay:(BOOL)enableAutoPlay
{
    [_streamAdHelper setAutoPlay:enableAutoPlay];
}

- (void)startAdAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_streamAdHelper isAdAtIndexPath:indexPath] == NO) {
        return;
    }
    [_streamAdHelper startAdAtPosition:[self indexPathToPosition:indexPath]];
}

- (void)stopAdAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_streamAdHelper isAdAtIndexPath:indexPath] == NO) {
        return;
    }
    [_streamAdHelper stopAdAtPosition:[self indexPathToPosition:indexPath]];
}

#pragma mark - private method
- (void)updateVisiblePositions
{
    NSArray* cells = [_tableView visibleCells];
    int firstPos = -1;
    int lastPos = -1;
    if (cells.count > 0) {
        firstPos = [self indexPathToPosition:[_tableView indexPathForCell:[cells firstObject]]];
        lastPos = [self indexPathToPosition:[_tableView indexPathForCell:[cells lastObject]]];
    }
   
    [_streamAdHelper updateVisibleCellsFromPosition:firstPos toPosition:lastPos];
}

#pragma mark - CEStreamAdHelperDelegate
- (BOOL)CEStreamADDidLoadAdAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger lastSectionIndex = self.tableView.numberOfSections - 1;
    if (indexPath.section == lastSectionIndex) {
        if (indexPath.row >= [self.tableView numberOfRowsInSection:lastSectionIndex]) {
            return NO;
        }
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    return YES;
}

- (void)CEStreamADDidRemoveAdsAtIndexPaths:(NSArray *)indexPaths
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)CEStreamADOnPulldownAnimation
{
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [[self tableView] beginUpdates];
        [[self tableView] endUpdates];
    } completion:^(BOOL finished) {
        
    }];
}

- (int)indexPathToPosition:(NSIndexPath *)indexPath
{
    if (indexPath == nil) {
        return -1;
    }
    
    NSUInteger section = [indexPath section];
    NSUInteger rows = [indexPath row];
    int position = 0;
    
    for (int i=0; i<section; i++) {
        position += [_tableView numberOfRowsInSection:i];
    }
    position += rows;
    return position;
}

- (NSIndexPath *)positionToIndexPath:(int)position
{
    NSUInteger section = 0;
    NSUInteger numOfSection = _tableView.numberOfSections;
    for (int i=0; i<numOfSection; i++) {
        NSUInteger numOfRows = [_tableView numberOfRowsInSection:i];
        if (position > numOfRows) {
            position -= numOfRows;
            section ++;
        } else {
            break;
        }
    }
    
    // the cell count in tableView is not enougth for AD to insert
    if (section >= _tableView.numberOfSections) {
        return nil;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:section];
    return indexPath;
}

- (BOOL)isIdle
{
    return (![self.tableView isDecelerating] && ![self.tableView isDragging]);
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.originalDataSource numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numberOfItems = [self.originalDataSource tableView:tableView numberOfRowsInSection:section];
    
    return [self.streamAdHelper adjustedNumberOfItems:numberOfItems inSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_enableAd) {
        UIView *adView = [_streamAdHelper loadAdAtIndexPath:indexPath];
        if (adView) {
            NSString *identifier = [NSString stringWithFormat:@"ADCell_%d_%d", (int)[indexPath section], (int)[indexPath row]];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
           
            [[cell contentView] addSubview:adView];
            
            [adView setFrame:CGRectMake((SCREEN_WIDTH - adView.bounds.size.width)/2.0f, _adVerticalMargin, adView.bounds.size.width, adView.bounds.size.height)];
            [cell.contentView setBackgroundColor:_adBgColor];
            [cell setBackgroundColor:_adBgColor];
           
            if (_customizedAdCellBlock) {
                _customizedAdCellBlock(cell);
            }
            
            return cell;
        }
    }
    NSIndexPath *originalIndexPath = [_streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
//    NSLog(@"(%d, %d) -> (%d, %d)", indexPath.section, indexPath.row, originalIndexPath.section, originalIndexPath.row);
    return [self.originalDataSource tableView:tableView cellForRowAtIndexPath:originalIndexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_streamAdHelper isAdAtIndexPath:indexPath]) {
        return NO;
    }
    
    id<UITableViewDataSource> datasource = self.originalDataSource;
    if ([datasource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        NSIndexPath *origPath = [_streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        return [datasource tableView:tableView canEditRowAtIndexPath:origPath];
    }
    
    // When the data source doesn't implement tableView:canEditRowAtIndexPath:, Apple assumes the cells are editable.  So we return NO.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.originalDataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        NSIndexPath *origPath = [_streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        if (origPath) {
            return [self.originalDataSource tableView:tableView canMoveRowAtIndexPath:origPath];
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.originalDataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        NSIndexPath *origPath = [_streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        if (origPath) {
            [self.originalDataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:origPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if ([_streamAdHelper isAdAtIndexPath:sourceIndexPath]) {
        // Can't move an ad explicitly.
        return;
    }
    
    id<UITableViewDataSource> dataSource = self.originalDataSource;
    if ([dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        NSIndexPath *origSource = [self.streamAdHelper originalIndexPathForAdjustedIndexPath:sourceIndexPath];
        NSIndexPath *origDestination = [self.streamAdHelper originalIndexPathForAdjustedIndexPath:destinationIndexPath];
        [dataSource tableView:tableView moveRowAtIndexPath:origSource toIndexPath:origDestination];
    }
}

#pragma mark - <UITableViewDelegate>

// We don't override the following:
//
// -tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath - No need to override because
// targeting is typically based on the adjusted paths.
//
// -tableView:accessoryTypeForRowWithIndexPath - Deprecated, and causes a runtime exception.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.streamAdHelper isAdAtIndexPath:indexPath]) {
        return [self.streamAdHelper getAdSizeAtIndexPath:indexPath].height + 2*_adVerticalMargin;
    }
    
    if ([self.originalDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        NSIndexPath *originalIndexPath = [self.streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        return [self.originalDelegate tableView:tableView heightForRowAtIndexPath:originalIndexPath];
    }
    
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.originalDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        NSIndexPath *origPath = [_streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        if (origPath) {
            [self.originalDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:origPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.originalDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        NSIndexPath *origPath = [_streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        if (origPath) {
            [self.originalDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:origPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInvocation *invocation = [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:shouldHighlightRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
    
    return [CEAdInvocation boolResultForInvocation:invocation defaultValue:YES];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:didHighlightRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:didUnhighlightRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.streamAdHelper isAdAtIndexPath:indexPath]) {
        return indexPath;
    }
   
    id<UITableViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        NSIndexPath *origPath = [self.streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        NSIndexPath *origResult = [delegate tableView:tableView willSelectRowAtIndexPath:origPath];
        return [self.streamAdHelper adjustedIndexPathForOriginalIndexPath:origResult];
    }
    
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.streamAdHelper isAdAtIndexPath:indexPath]) {
        return indexPath;
    }
    
    id<UITableViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        NSIndexPath *origPath = [self.streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        NSIndexPath *origResult = [delegate tableView:tableView willDeselectRowAtIndexPath:origPath];
        return [self.streamAdHelper adjustedIndexPathForOriginalIndexPath:origResult];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.streamAdHelper isAdAtIndexPath:indexPath]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
   
    [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:didSelectRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:didDeselectRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.streamAdHelper isAdAtIndexPath:indexPath]) {
        return UITableViewCellEditingStyleNone;
    }
    
    id<UITableViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
        NSIndexPath *origPath = [self.streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        return [delegate tableView:tableView editingStyleForRowAtIndexPath:origPath];
    }
    
    // Apple returns UITableViewCellEditingStyleDelete by default when the cell is editable.  So we'll do the same.
    // We'll also return UITableViewCellEditingStyleNone if the cell isn't editable.
    BOOL editable = [self tableView:tableView canEditRowAtIndexPath:indexPath];
    
    if (editable) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInvocation *invocation = [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
    
    return [CEAdInvocation resultForInvocation:invocation defaultValue:@"Delete"];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInvocation *invocation = [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
    
    return [CEAdInvocation boolResultForInvocation:invocation defaultValue:YES];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:willBeginEditingRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:didEndEditingRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInvocation *invocation = [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:indentationLevelForRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
    
    return [CEAdInvocation integerResultForInvocation:invocation
                                         defaultValue:UITableViewCellEditingStyleNone];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInvocation *invocation = [CEAdInvocation invokeForTarget:self.originalDelegate with2ArgSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:) firstArg:tableView secondArg:indexPath streamAdHelper:self.streamAdHelper];
    
    return [CEAdInvocation boolResultForInvocation:invocation defaultValue:NO];
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.streamAdHelper isAdAtIndexPath:indexPath]) {
        // Can't copy or paste to an ad.
        return NO;
    }
    
    id<UITableViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]) {
        NSIndexPath *origPath = [self.streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        return [delegate tableView:tableView canPerformAction:action forRowAtIndexPath:origPath withSender:sender];
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    if ([self.streamAdHelper isAdAtIndexPath:indexPath]) {
        // Can't copy or paste to an ad.
        return;
    }
    
    id<UITableViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]) {
        NSIndexPath *origPath = [self.streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        [delegate tableView:tableView performAction:action forRowAtIndexPath:origPath withSender:sender];
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateVisiblePositions];
    
    id<UITableViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        [_streamAdHelper updateAdStatus];
    }
    
    id<UITableViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_streamAdHelper updateAdStatus];
    
    id<UITableViewDelegate> delegate = self.originalDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [delegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - Method Forwarding

- (BOOL)isKindOfClass:(Class)aClass {
    return [super isKindOfClass:aClass] ||
    [self.originalDataSource isKindOfClass:aClass] ||
    [self.originalDelegate isKindOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [super conformsToProtocol:aProtocol] ||
    [self.originalDelegate conformsToProtocol:aProtocol] ||
    [self.originalDataSource conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] ||
    [self.originalDataSource respondsToSelector:aSelector] ||
    [self.originalDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.originalDataSource respondsToSelector:aSelector]) {
        return self.originalDataSource;
    } else if ([self.originalDelegate respondsToSelector:aSelector]) {
        return self.originalDelegate;
    } else {
        return [super forwardingTargetForSelector:aSelector];
    }
}
@end

#pragma mark -
@implementation UITableView (CETableViewAdHelper)
+ (void)swizzleWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    // ...
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        [self swizzleWithOriginalSelector:@selector(setDelegate:) swizzledSelector:@selector(ce_setDelegate:)];
//        [self swizzleWithOriginalSelector:@selector(delegate) swizzledSelector:@selector(ce_delegate)];
//        [self swizzleWithOriginalSelector:@selector(setDataSource:) swizzledSelector:@selector(ce_setDataSource:)];
//        [self swizzleWithOriginalSelector:@selector(dataSource) swizzledSelector:@selector(ce_dataSource)];
//        [self swizzleWithOriginalSelector:@selector(beginUpdates) swizzledSelector:@selector(ce_beginUpdates)];
//        [self swizzleWithOriginalSelector:@selector(endUpdates) swizzledSelector:@selector(ce_endUpdates)];
//        [self swizzleWithOriginalSelector:@selector(reloadData) swizzledSelector:@selector(ce_reloadData)];
//        [self swizzleWithOriginalSelector:@selector(insertRowsAtIndexPaths:withRowAnimation:) swizzledSelector:@selector(ce_insertRowsAtIndexPaths:withRowAnimation:)];
//        [self swizzleWithOriginalSelector:@selector(deleteRowsAtIndexPaths:withRowAnimation:) swizzledSelector:@selector(ce_deleteRowsAtIndexPaths:withRowAnimation:)];
//        [self swizzleWithOriginalSelector:@selector(reloadRowsAtIndexPaths:withRowAnimation:) swizzledSelector:@selector(ce_reloadRowsAtIndexPaths:withRowAnimation:)];
//        [self swizzleWithOriginalSelector:@selector(moveRowAtIndexPath:toIndexPath:) swizzledSelector:@selector(ce_moveRowAtIndexPath:toIndexPath:)];
//        [self swizzleWithOriginalSelector:@selector(insertSections:withRowAnimation:) swizzledSelector:@selector(ce_insertSections:withRowAnimation:)];
//        [self swizzleWithOriginalSelector:@selector(deleteSections:withRowAnimation:) swizzledSelector:@selector(ce_deleteSections:withRowAnimation:)];
//        [self swizzleWithOriginalSelector:@selector(reloadSections:withRowAnimation:) swizzledSelector:@selector(ce_reloadSections:withRowAnimation:)];
//        [self swizzleWithOriginalSelector:@selector(moveSection:toSection:) swizzledSelector:@selector(ce_moveSection:toSection:)];
//        [self swizzleWithOriginalSelector:@selector(cellForRowAtIndexPath:) swizzledSelector:@selector(ce_cellForRowAtIndexPath:)];
//        [self swizzleWithOriginalSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:) swizzledSelector:@selector(ce_dequeueReusableCellWithIdentifier:forIndexPath:)];
//        [self swizzleWithOriginalSelector:@selector(deselectRowAtIndexPath:animated:) swizzledSelector:@selector(ce_deselectRowAtIndexPath:animated:)];
//        [self swizzleWithOriginalSelector:@selector(indexPathForCell:) swizzledSelector:@selector(ce_indexPathForCell:)];
//        [self swizzleWithOriginalSelector:@selector(indexPathForRowAtPoint:) swizzledSelector:@selector(ce_indexPathForRowAtPoint:)];
//        [self swizzleWithOriginalSelector:@selector(indexPathForSelectedRow) swizzledSelector:@selector(ce_indexPathForSelectedRow)];
//        [self swizzleWithOriginalSelector:@selector(indexPathsForRowsInRect:) swizzledSelector:@selector(ce_indexPathsForRowsInRect:)];
//        [self swizzleWithOriginalSelector:@selector(indexPathsForSelectedRows) swizzledSelector:@selector(ce_indexPathsForSelectedRows)];
//        [self swizzleWithOriginalSelector:@selector(indexPathsForVisibleRows) swizzledSelector:@selector(ce_indexPathsForVisibleRows)];
//        [self swizzleWithOriginalSelector:@selector(rectForRowAtIndexPath:) swizzledSelector:@selector(ce_rectForRowAtIndexPath:)];
//        [self swizzleWithOriginalSelector:@selector(scrollToRowAtIndexPath:atScrollPosition:animated:) swizzledSelector:@selector(ce_scrollToRowAtIndexPath:atScrollPosition:animated:)];
//        [self swizzleWithOriginalSelector:@selector(selectRowAtIndexPath:animated:scrollPosition:) swizzledSelector:@selector(ce_selectRowAtIndexPath:animated:scrollPosition:)];
//        [self swizzleWithOriginalSelector:@selector(visibleCells) swizzledSelector:@selector(ce_visibleCells)];
    });
}

static char kAdHelperKey;
- (void)ce_setAdHelper:(CETableViewADHelper *)helper
{
    objc_setAssociatedObject(self, &kAdHelperKey, helper, OBJC_ASSOCIATION_ASSIGN);
}

- (CETableViewADHelper *)ce_adHelper
{
    return objc_getAssociatedObject(self, &kAdHelperKey);
}

- (void)ce_setDelegate:(id<UITableViewDelegate>)delegate
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    
    if (adHelper) {
        adHelper.originalDelegate = delegate;
    } else {
        [self setDelegate:delegate];
    }
}

- (id<UITableViewDelegate>)ce_delegate
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    
    if (adHelper) {
        return adHelper.originalDelegate;
    } else {
        return [self delegate];
    }
}

- (void)ce_setDataSource:(id<UITableViewDataSource>)dataSource
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    
    if (adHelper) {
        adHelper.originalDataSource = dataSource;
    } else {
        [self setDataSource:dataSource];
    }
}

- (id<UITableViewDataSource>)ce_dataSource
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    
    if (adHelper) {
        return adHelper.originalDataSource;
    } else {
        return [self dataSource];
    }
}

- (void)ce_reloadData
{
    [self reloadData];
}

- (CGRect)ce_rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = indexPath;
    
    if (adHelper) {
        adjustedIndexPath = [adHelper.streamAdHelper adjustedIndexPathForOriginalIndexPath:adjustedIndexPath];
    }
    
    if (!indexPath || adjustedIndexPath) {
        return [self rectForRowAtIndexPath:adjustedIndexPath];
    } else {
        return CGRectZero;
    }
}

- (NSIndexPath *)ce_indexPathForRowAtPoint:(CGPoint)point
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = [self indexPathForRowAtPoint:point];
    
    if (adHelper) {
        adjustedIndexPath = [adHelper.streamAdHelper originalIndexPathForAdjustedIndexPath:adjustedIndexPath];
    }
    
    return adjustedIndexPath;
}

- (NSIndexPath *)ce_indexPathForCell:(UITableViewCell *)cell
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = [self indexPathForCell:cell];
    
    if (adHelper) {
        adjustedIndexPath = [adHelper.streamAdHelper originalIndexPathForAdjustedIndexPath:adjustedIndexPath];
    }
    
    return adjustedIndexPath;
}

- (NSArray *)ce_indexPathsForRowsInRect:(CGRect)rect
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSArray *indexPaths = [self indexPathsForRowsInRect:rect];
    
    if (adHelper) {
        indexPaths = [adHelper.streamAdHelper originalIndexPathsForAdjustedIndexPaths:indexPaths];
    }
    
    return indexPaths;
}

- (UITableViewCell *)ce_cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = indexPath;
    
    if (adHelper) {
        adjustedIndexPath = [adHelper.streamAdHelper adjustedIndexPathForOriginalIndexPath:adjustedIndexPath];
    }
    
    return [self cellForRowAtIndexPath:adjustedIndexPath];
}

- (NSArray *)ce_visibleCells
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    
    if (adHelper) {
        NSArray *indexPaths = [self indexPathsForVisibleRows];
        NSMutableArray *visibleCells = [NSMutableArray array];
        for (NSIndexPath *indexPath in indexPaths) {
            UITableViewCell *tmpCell = [self cellForRowAtIndexPath:indexPath];
            if (tmpCell) {
                [visibleCells addObject:tmpCell];
            }
        }
        return visibleCells;
    } else {
        return [self visibleCells];
    }
}

- (NSArray *)ce_indexPathsForVisibleRows
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSArray *adjustedIndexPaths = [self indexPathsForVisibleRows];
   
    if (adHelper) {
        adjustedIndexPaths = [adHelper.streamAdHelper originalIndexPathsForAdjustedIndexPaths:adjustedIndexPaths];
    }
    
    return adjustedIndexPaths;
}

- (void)ce_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = indexPath;
    
    if (adHelper && indexPath.row != NSNotFound) {
        adjustedIndexPath = [adHelper.streamAdHelper adjustedIndexPathForOriginalIndexPath:adjustedIndexPath];
    }
    
    [self scrollToRowAtIndexPath:adjustedIndexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)ce_beginUpdates
{
    [self beginUpdates];
}

- (void)ce_endUpdates
{
    [self endUpdates];
}

- (void)ce_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    
    if (adHelper) {
        [adHelper.streamAdHelper insertSections:sections];
    }
    
    [self insertSections:sections withRowAnimation:animation];
}

- (void)ce_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    
    if (adHelper) {
        [adHelper.streamAdHelper deleteSections:sections];
    }
    
    [self deleteSections:sections withRowAnimation:animation];
}

- (void)ce_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadSections:sections withRowAnimation:animation];
}

- (void)ce_moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    
    if (adHelper) {
        [adHelper.streamAdHelper moveSection:section toSection:newSection];
    }
    
    [self moveSection:section toSection:newSection];
}

- (void)ce_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSArray *adjustedIndexPaths = indexPaths;
    
    if (adHelper) {
        [adHelper.streamAdHelper insertItemsAtIndexPaths:indexPaths];
        adjustedIndexPaths = [adHelper.streamAdHelper adjustedIndexPathsForOriginalIndexPaths:indexPaths];
    }
    
    // We perform the actual UI insertion AFTER updating the stream ad placer's
    // data, because the insertion can trigger queries to the data source, which
    // needs to reflect the post-insertion state.
    [self insertRowsAtIndexPaths:adjustedIndexPaths withRowAnimation:animation];
}

- (void)ce_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSArray *adjustedIndexPaths = indexPaths;
    
    // We need to wrap the delete process in begin/end updates in case any ad
    // cells are also deleted. MPStreamadHelper's deleteItemsAtIndexPaths: can
    // call the delegate's didRemoveAdsAtIndexPaths, which will remove those
    // ads from the tableview.
    [self beginUpdates];
    if (adHelper) {
        // We need to obtain the adjusted index paths to delete BEFORE we
        // update the stream ad placer's data.
        adjustedIndexPaths = [adHelper.streamAdHelper adjustedIndexPathsForOriginalIndexPaths:indexPaths];
        [adHelper.streamAdHelper deleteItemsAtIndexPaths:indexPaths];
    }
    
    // We perform the actual UI deletion AFTER updating the stream ad placer's
    // data, because the deletion can trigger queries to the data source, which
    // needs to reflect the post-deletion state.
    [self deleteRowsAtIndexPaths:adjustedIndexPaths withRowAnimation:animation];
    [self endUpdates];
}

- (void)ce_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSArray *adjustedIndexPaths = indexPaths;
    
    if (adHelper) {
        adjustedIndexPaths = [adHelper.streamAdHelper adjustedIndexPathsForOriginalIndexPaths:indexPaths];
    }
    
    [self reloadRowsAtIndexPaths:adjustedIndexPaths withRowAnimation:animation];
}

- (void)ce_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedFrom = indexPath;
    NSIndexPath *adjustedTo = newIndexPath;
    
    if (adHelper) {
        // We need to obtain the adjusted index paths to move BEFORE we
        // update the stream ad placer's data.
        adjustedFrom = [adHelper.streamAdHelper adjustedIndexPathForOriginalIndexPath:indexPath];
        adjustedTo = [adHelper.streamAdHelper adjustedIndexPathForOriginalIndexPath:newIndexPath];
        
        [adHelper.streamAdHelper moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    
    // We perform the actual UI operation AFTER updating the stream ad placer's
    // data, because the operation can trigger queries to the data source, which
    // needs to reflect the post-operation state.
    [self moveRowAtIndexPath:adjustedFrom toIndexPath:adjustedTo];
}

- (NSIndexPath *)ce_indexPathForSelectedRow
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = [self indexPathForSelectedRow];
    
    if (adHelper) {
        adjustedIndexPath = [adHelper.streamAdHelper originalIndexPathForAdjustedIndexPath:adjustedIndexPath];
    }
    
    return adjustedIndexPath;
}

- (NSArray *)ce_indexPathsForSelectedRows
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSArray *adjustedIndexPaths = [self indexPathsForSelectedRows];
    
    if (adHelper) {
        adjustedIndexPaths = [adHelper.streamAdHelper originalIndexPathsForAdjustedIndexPaths:adjustedIndexPaths];
    }
    
    return adjustedIndexPaths;
}

- (void)ce_selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = indexPath;
    
    if (adHelper) {
        adjustedIndexPath = [adHelper.streamAdHelper adjustedIndexPathForOriginalIndexPath:indexPath];
    }
    
    if (!indexPath || adjustedIndexPath) {
        [self selectRowAtIndexPath:adjustedIndexPath animated:animated scrollPosition:scrollPosition];
    }
}

- (void)ce_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = indexPath;
    
    if (adHelper) {
        adjustedIndexPath = [adHelper.streamAdHelper adjustedIndexPathForOriginalIndexPath:indexPath];
    }
    
    if (!indexPath || adjustedIndexPath) {
        [self deselectRowAtIndexPath:adjustedIndexPath animated:animated];
    }
}

- (id)ce_dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    CETableViewADHelper *adHelper = [self ce_adHelper];
    NSIndexPath *adjustedIndexPath = indexPath;
    
    if (adHelper) {
        adjustedIndexPath = [adHelper.streamAdHelper adjustedIndexPathForOriginalIndexPath:indexPath];
    }
    
    if (!indexPath || adjustedIndexPath) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= ce_IOS_6_0
        if ([self respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)]) {
            return [self dequeueReusableCellWithIdentifier:identifier forIndexPath:adjustedIndexPath];
        } else {
            return [self dequeueReusableCellWithIdentifier:identifier];
        }
#endif
    } else {
        return nil;
    }
}
@end
