//
//  StreamTableViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/3/20.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "StreamTableViewController.h"
#import "LayoutUtils.h"
#import "StreamADHelper.h"

#define ROWS_IN_SECTION 300

@interface StreamTableViewController ()
@property (nonatomic, strong) NSMutableArray *contentImages;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) StreamADHelper *streamHelper;
@property (nonatomic, strong) NSString *sectionName;
@end

@implementation StreamTableViewController

- (instancetype)initWithPlacementName:(NSString *)placementName
{
    self = [super init];
    if (self) {
        _contentImages = [[NSMutableArray alloc] init];
        _dataSource = [[NSMutableArray alloc] init];
        _sectionName = @"business";
        _streamHelper = [[StreamADHelper alloc] initWithPlacement:placementName];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.0]];
    
    [self loadContentImages];
    [self prepareDataSource];
    
    if (_streamHelper) {
        [_streamHelper setDelegate:self];
        [_streamHelper preroll];
    }
    [[self tableView] reloadData];
    [_streamHelper updateVisiblePosition:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_streamHelper setActive:YES];
    [_streamHelper scrollViewStateChanged];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_streamHelper setActive:NO];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = (int)[indexPath row];
    UIView *adView = [_streamHelper requestADAtPosition:index];
    if (adView != nil) {
        NSString *identifier = [NSString stringWithFormat:@"ADCell_%@_%d", _sectionName, (int)[indexPath row]];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else {
        }
        [[cell contentView] addSubview:adView];
        
        return cell;
    } else {
        NSDictionary *dict = [_dataSource objectAtIndex:index];
        int imgId = [[dict objectForKey:@"imgId"] intValue];
        NSString *identifier = [NSString stringWithFormat:@"DemoTableViewCell_%d", imgId];
        if (index == 0) {
            identifier = [NSString stringWithFormat:@"DemoTableViewCell_hasTopMargin"];
        }
        
        UITableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            if ((index % 5) < [_contentImages count]) {
                UIImage *dataImg = [_contentImages objectAtIndex:imgId];
                UIImageView *dataImgView = [[UIImageView alloc] initWithImage:dataImg];
                CGFloat dataHeight = [LayoutUtils getRelatedHeightWithOriWidth:dataImg.size.width OriHeight:dataImg.size.height] + [LayoutUtils getScaleWidth:20];
                
                [dataImgView setFrame:CGRectMake([LayoutUtils getScaleWidth:18], [LayoutUtils getScaleWidth:10], [LayoutUtils getScaleWidth:684], [LayoutUtils getRelatedHeightWithOriWidth:684 OriHeight:dataImg.size.height])];
                
                float topPadding = 0;
                if (index == 0) {
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
    NSUInteger rowIndex = indexPath.row;
    if (rowIndex < [_dataSource count]) {
        NSDictionary *dict = [_dataSource objectAtIndex:rowIndex];
        return [[dict objectForKey:@"height"] floatValue];
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = (int)[indexPath row];
    if ([_streamHelper isAdAtPos:index]) {
        return;
    }
    
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

- (void)prepareDataSource
{
    for (int i=0; i<ROWS_IN_SECTION; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        float topPadding = 0;
        if (i == 0) {
            topPadding = [LayoutUtils getScaleWidth:10];
        }
        
        int imgId = (i%5);
        if (imgId < [_contentImages count]) {
            [dict setObject:[NSNumber numberWithInt:imgId] forKey:@"imgId"];
            UIImage *img = [_contentImages objectAtIndex:imgId];
            [dict setObject:[NSNumber numberWithFloat:topPadding + [LayoutUtils getScaleWidth:20] + [LayoutUtils getRelatedHeightWithOriWidth:684 OriHeight:img.size.height]] forKey: @"height"];
            [dict setObject:[NSNumber numberWithInt:i] forKey:@"articleId"];
        } else {
            [dict setObject:[NSNumber numberWithFloat:50] forKey: @"height"];
        }
        [_dataSource addObject:dict];
    }
}

#pragma mark - StreamADHelperDelegate
- (int)onADLoaded:(UIView *)adView atPosition:(int)position isPreroll:(BOOL)isPreroll
{
    // Don't place ad at the first place!!
    position = MAX(1, position);
    if ([_dataSource count] >= position) {
        if (isPreroll) {
            NSMutableDictionary *adDict = [[NSMutableDictionary alloc] init];
            [adDict setObject:[NSNumber numberWithInt:adView.bounds.size.height] forKey:@"height"];
            
            NSArray *indexPathsToAdd = @[[NSIndexPath indexPathForRow:position inSection:0]];
            [[self tableView] beginUpdates];
            [_dataSource insertObject:adDict atIndex:position];
            [[self tableView] insertRowsAtIndexPaths:indexPathsToAdd
                                    withRowAnimation:UITableViewRowAnimationNone];
            [[self tableView] endUpdates];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(){
                NSMutableDictionary *adDict = [[NSMutableDictionary alloc] init];
                [adDict setObject:[NSNumber numberWithInt:adView.bounds.size.height] forKey:@"height"];
                
                NSArray *indexPathsToAdd = @[[NSIndexPath indexPathForRow:position inSection:0]];
                [[self tableView] beginUpdates];
                [_dataSource insertObject:adDict atIndex:position];
                [[self tableView] insertRowsAtIndexPaths:indexPathsToAdd
                                        withRowAnimation:UITableViewRowAnimationNone];
                [[self tableView] endUpdates];
            });
        }
        return position;
    } else {
        return -1;
    }
}

- (void)onADAnimation:(UIView *)adView atPosition:(int)position
{
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [[self tableView] beginUpdates];
        [[_dataSource objectAtIndex:position] setObject:[NSNumber numberWithInt:adView.bounds.size.height] forKey:@"height"];
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
@end
