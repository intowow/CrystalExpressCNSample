//
//  StreamTableViewController.m
//  crystalexpress
//
//  Created by roylo on 2015/3/20.
//  Copyright (c) 2015年 intowow. All rights reserved.
//

#import "StreamTableViewController.h"
#import "LayoutUtils.h"
#import "CETableViewADHelper.h"

#define NUM_OF_SECTIONS 3
#define ROWS_IN_SECTION 30
#define AD_VERTICAL_MARGIN 5
#define AD_HORIZONTAL_MARGIN 5

@interface StreamTableViewController ()
@property (nonatomic, strong) NSMutableArray *contentImages;
@property (nonatomic, strong) NSMutableArray *dataSources;
@property (nonatomic, strong) CETableViewADHelper *adHelper;
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, strong) NSMutableArray *appAdIndexPaths;
@property (nonatomic, strong) NSString *placementName;
@property (nonatomic, strong) NSString *tagName;
@end

@implementation StreamTableViewController

- (instancetype)initWithPlacementName:(NSString *)placementName
{
    self = [super init];
    if (self) {
        _contentImages = [[NSMutableArray alloc] init];
        _dataSources = [[NSMutableArray alloc] init];
        _sectionName = @"business";
        _appAdIndexPaths = [[NSMutableArray alloc] init];
        _placementName = placementName;
    }
    return self;
}

- (instancetype)initWithAdTagName:(NSString *)tagName
{
    self = [super init];
    if (self) {
        _contentImages = [[NSMutableArray alloc] init];
        _dataSources = [[NSMutableArray alloc] init];
        _sectionName = @"business";
        _appAdIndexPaths = [[NSMutableArray alloc] init];
        _tagName = tagName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.0]];
    
    [self loadContentImages];
    [self prepareDataSources];
    [self setupStreamADHelper];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_adHelper onShow];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_adHelper onHide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setupStreamADHelper
{
    if (_placementName != nil && ![_placementName isEqual:@""]) {
        _adHelper = [CETableViewADHelper helperWithTableView:self.tableView viewController:self placement:_placementName];
    } else {
        _adHelper = [CETableViewADHelper helperWithTableView:self.tableView viewController:self adTag:_tagName];
    }
    
    [_adHelper loadAd];
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
            if (row == 0 && section == 0) {
                topPadding = [LayoutUtils getScaleWidth:10];
            }
            
            UIView *dataContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, topPadding, self.view.bounds.size.width, dataHeight)];
            
            [dataContainerView addSubview:dataImgView];
            [dataContainerView setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.0]];
            [[cell contentView] setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.0]];
            [[cell contentView] addSubview:dataContainerView];
        }
    }
    
    if ([_appAdIndexPaths containsObject:indexPath]) {
        cell.contentView.layer.borderColor = [UIColor redColor].CGColor;
        cell.contentView.layer.borderWidth = 1.0f;
    } else {
        cell.contentView.layer.borderWidth = 0.0f;
    }
    return cell;
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

@end
