//
//  DemoStreamTableViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/3/26.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "DemoStreamTableViewController.h"
#import "LayoutUtils.h"
#import "DemoDetailContentViewController.h"
#import <SSPullToRefresh.h>

#define NUM_OF_SECTIONS 3
#define ROWS_IN_SECTION 100

@interface DemoStreamTableViewController () <SSPullToRefreshViewDelegate>
@property (nonatomic, strong) NSMutableArray *contentImages;
@property (nonatomic, strong) NSMutableArray *dataSources;
@property (nonatomic, assign) CGFloat adVerticalMargin;
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;
@end

@implementation DemoStreamTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentImages = [[NSMutableArray alloc] init];
        _dataSources = [[NSMutableArray alloc] init];
        _adVerticalMargin = 5.0f;
        _pullToRefreshView = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.0]];
    
    [self loadContentImages];
    [self prepareDataSources];
   
    if (_streamHelper) {
        [_streamHelper setDelegate:self];
        [_streamHelper setPreferAdWidth:[LayoutUtils getScaleWidth:680.0f]];
        [_streamHelper preroll];
    }
    [[self tableView] reloadData];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_streamHelper updateVisiblePosition:self.tableView];

    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_streamHelper scrollViewStateChanged];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_streamHelper scrollViewStateChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataSources objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *adView = [_streamHelper requestADAtPosition:indexPath];
    if (adView != nil) {
        NSString *identifier = [NSString stringWithFormat:@"ADCell_%@_%d_%d", _sectionName, (int)[indexPath section], (int)[indexPath row]];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        [[cell contentView] addSubview:adView];

        [adView setFrame:CGRectMake((SCREEN_WIDTH - adView.bounds.size.width)/2.0f, _adVerticalMargin, adView.bounds.size.width, adView.bounds.size.height)];
//
        [[cell contentView] setBackgroundColor:[UIColor colorWithWhite:0.905 alpha:1.0]];
        
        return cell;
    } else {
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];
        NSDictionary *dict = [[_dataSources objectAtIndex:section] objectAtIndex:row];
        int imgId = [[dict objectForKey:@"imgId"] intValue];
        NSString *identifier = [NSString stringWithFormat:@"DemoTableViewCell_%d", imgId];
        if (section == 0 && row == 0) {
            identifier = [NSString stringWithFormat:@"DemoTableViewCell_hasTopMargin"];
        }
        
        UITableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            if ((row % 5) < [_contentImages count]) {
                UIImage *dataImg = [_contentImages objectAtIndex:imgId];
                UIImageView *dataImgView = [[UIImageView alloc] initWithImage:dataImg];
                CGFloat dataHeight = [LayoutUtils getRelatedHeightWithOriWidth:dataImg.size.width OriHeight:dataImg.size.height] + [LayoutUtils getScaleWidth:20];
                
                [dataImgView setFrame:CGRectMake([LayoutUtils getScaleWidth:18], [LayoutUtils getScaleWidth:10], [LayoutUtils getScaleWidth:684], [LayoutUtils getRelatedHeightWithOriWidth:684 OriHeight:dataImg.size.height])];
                
                float topPadding = 0;
                if (section == 0 && row == 0) {
                    topPadding = [LayoutUtils getScaleWidth:10];
                }
               
                UIView *dataContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, topPadding, self.view.bounds.size.width, dataHeight)];
                
                [dataContainerView addSubview:dataImgView];
                [dataContainerView setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.0]];
                [[cell contentView] setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.0]];
                [[cell contentView] addSubview:dataContainerView];
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger sectionIndex = indexPath.section;
    NSUInteger rowIndex = indexPath.row;
    if (sectionIndex < [_dataSources count]) {
        NSArray *dataSource = [_dataSources objectAtIndex:sectionIndex];
        if (rowIndex < [dataSource count]) {
            NSDictionary *dict = [dataSource objectAtIndex:rowIndex];
            return [[dict objectForKey:@"height"] floatValue];
        }
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_streamHelper isAdAtIndexPath:indexPath]) {
        return;
    }

    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSArray *dataSource = [_dataSources objectAtIndex:section];
    int articleId = [[[dataSource objectAtIndex:row] objectForKey:@"articleId"] intValue];
    DemoDetailContentViewController *detailVC = [[DemoDetailContentViewController alloc] initWithIndex:articleId];
    [detailVC setDelegate:_delegate];
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

#pragma mark - private method
- (void)loadContentImages
{
    for (int i=1; i<=5; i++) {
        NSString *imgName = [NSString stringWithFormat:@"asset.bundle/%@_%d.jpg", _sectionName, i];
        UIImage *img = [UIImage imageNamed:imgName];
        if (img) {
            [_contentImages addObject:img];
        }
    }
}

- (void)prepareDataSources
{
    [_dataSources removeAllObjects];
    int articleIndex = 0;
    
    for (int i=0; i<NUM_OF_SECTIONS; i++) {
        NSMutableArray *dataSource = [[NSMutableArray alloc] init];
        for (int j=0; j<ROWS_IN_SECTION; j++) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            float topPadding = 0;
            if (i == 0 && j == 0) {
                topPadding = [LayoutUtils getScaleWidth:10];
            }
            
            int imgId = (j%5);
            if (imgId < [_contentImages count]) {
                [dict setObject:[NSNumber numberWithInt:imgId] forKey:@"imgId"];
                UIImage *img = [_contentImages objectAtIndex:imgId];
                [dict setObject:[NSNumber numberWithFloat:topPadding + [LayoutUtils getScaleWidth:20] + [LayoutUtils getRelatedHeightWithOriWidth:684 OriHeight:img.size.height]] forKey: @"height"];
                [dict setObject:[NSNumber numberWithInt:articleIndex] forKey:@"articleId"];
                articleIndex++;
            } else {
                [dict setObject:[NSNumber numberWithFloat:50] forKey: @"height"];
            }
            [dataSource addObject:dict];
        }
        [_dataSources addObject:dataSource];
    }
}

#pragma mark - StreamADHelperDelegate
- (NSIndexPath *)onADLoaded:(UIView *)adView atIndexPath:(NSIndexPath *)indexPath isPreroll:(BOOL)isPreroll
{
    // Don't place ad at the first place!!
    int position = MAX(1, [indexPath row]);
    NSMutableArray *dataSource = [_dataSources objectAtIndex:[indexPath section]];
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForRow:position inSection:[indexPath section]];
    
    if ([dataSource count] >= position) {
        if (isPreroll) {
            NSMutableDictionary *adDict = [[NSMutableDictionary alloc] init];
            CGFloat adHeight = adView.bounds.size.height;
            [adDict setObject:[NSNumber numberWithFloat:adHeight + 2*_adVerticalMargin] forKey:@"height"];
            
            NSArray *indexPathsToAdd = @[finalIndexPath];
            [[self tableView] beginUpdates];
            [dataSource insertObject:adDict atIndex:position];
            [[self tableView] insertRowsAtIndexPaths:indexPathsToAdd
                                    withRowAnimation:UITableViewRowAnimationNone];
            [[self tableView] endUpdates];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(){
                NSMutableDictionary *adDict = [[NSMutableDictionary alloc] init];
                CGFloat adHeight = adView.bounds.size.height;
                [adDict setObject:[NSNumber numberWithFloat:adHeight + 2*_adVerticalMargin] forKey:@"height"];
                
                NSArray *indexPathsToAdd = @[finalIndexPath];
                [[self tableView] beginUpdates];
                [dataSource insertObject:adDict atIndex:position];
                [[self tableView] insertRowsAtIndexPaths:indexPathsToAdd
                                        withRowAnimation:UITableViewRowAnimationNone];
                [[self tableView] endUpdates];
            });
        }
        
        return finalIndexPath;
    } else {
        return nil;
    }
}

- (void)onADAnimation:(UIView *)adView atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *dataSource = [_dataSources objectAtIndex:[indexPath section]];
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [[self tableView] beginUpdates];
        [[dataSource objectAtIndex:[indexPath row]] setObject:[NSNumber numberWithInt:adView.bounds.size.height + 2*_adVerticalMargin] forKey:@"height"];
        [[self tableView] endUpdates];
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)checkIdle
{
    return (![[self tableView] isDecelerating] && ![[self tableView] isDragging]);
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_streamHelper scrollViewDidScroll:scrollView tableView:[self tableView]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        [_streamHelper scrollViewStateChanged];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_streamHelper scrollViewStateChanged];
}

#pragma mark - pull to refresh delegate
- (void)refresh
{
    [self.pullToRefreshView startLoading];
    [_streamHelper cleanADs];
    [self prepareDataSources];
    [self.tableView reloadData];
    [_streamHelper updateVisiblePosition:self.tableView];
    [self.pullToRefreshView finishLoading];
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self refresh];
}

@end
