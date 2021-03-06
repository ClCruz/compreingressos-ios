//
//  QMEspetaculosViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CoreMedia.h>
#import "QMEspetaculosViewController.h"
#import "QMGenre.h"
#import "QMEspetaculosRequester.h"
#import "SVProgressHUD.h"
#import "QMEspetaculoCell.h"
#import "QMWebViewController.h"
#import <Google/Analytics.h>

@interface QMEspetaculosViewController ()

@end

@implementation QMEspetaculosViewController {
    @private
    QMGenre          *_genre;
    UICollectionView *_collectionView;
    NSArray          *_espetaculos;
    CLLocation       *_location;
}

@synthesize genre          = _genre;
@synthesize collectionView = _collectionView;
@synthesize location       = _location;

- (void)viewDidLoad {
    [super viewDidLoad];
    _espetaculos = [[NSMutableArray alloc] init];

    [self configureCollectionView];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *titleForAnalytics = @"Espetáculos";
    if (_genre && _genre.title) {
        titleForAnalytics = [NSString stringWithFormat:@"%@ - %@", titleForAnalytics, _genre.title];
    }
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:titleForAnalytics];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCollectionView {
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self configureCollectionLayout];
    /* Registrando nib QMEspetaculoCell que está fora do storyboard na collecionView */
    UINib *cellNib = [UINib nibWithNibName:@"QMEspetaculoCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"QMEspetaculoCell"];
}

- (void)configureCollectionLayout {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat spacing;
    if (screenWidth <= 320) {
        spacing = 4.0f;
    }
    else if (screenWidth > 320 && screenWidth < 621) {
        spacing = 22.0f;
    }
    else {
        spacing = 35.0f;
    }
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:spacing];
    [layout setMinimumInteritemSpacing:spacing];
    [layout setSectionInset:UIEdgeInsetsMake(spacing, spacing, spacing, spacing)];
    [_collectionView setCollectionViewLayout:layout];
}

- (void)setGenre:(QMGenre *)genre {
    _genre = genre;
    self.navigationItem.title = genre.title;
}

- (void)requestData {
    if ([self isConnected]) {
        [SVProgressHUD dismiss];
        [SVProgressHUD show];
        _collectionView.alpha = 0.0;
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        if (_genre.searchTerm) {
            options[@"genero"] = _genre.searchTerm;
        }
        if (_location) {
            NSNumber *latitude = @(_location.coordinate.latitude);
            NSNumber *longitude = @(_location.coordinate.longitude);
            options[@"latitude"] = latitude;
            options[@"longitude"] = longitude;
        }
        [QMEspetaculosRequester requestEspetaculosWithOptions:options onCompleteBlock:^(NSArray *array, NSNumber *total) {
            _espetaculos = array;
            [_collectionView reloadData];
            [UIView animateWithDuration:0.3 animations:^{
                _collectionView.alpha = 1.0;
            }];
            [SVProgressHUD dismiss];
        } onFailBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
    } else {
        [SVProgressHUD dismiss];
        [self showNotConnectedError];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QMWebViewController *controller = segue.destinationViewController;
    QMEspetaculo *espetaculo = sender;
    [controller setGenre:_genre];
    [controller setEspetaculo:espetaculo];
    [self configureNextViewBackButtonWithTitle:@"Voltar"];
    [super prepareForSegue:segue sender:sender];
}

- (void)configureNextViewBackButtonWithTitle:(NSString *)title {
    UIBarButtonItem *nextViewBackButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:nil
                                                                          action:nil];
    [self.navigationItem setBackBarButtonItem:nextViewBackButton];
}


# pragma mark
# pragma mark - UICollectionView Datasource


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_espetaculos count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"QMEspetaculoCell";
    QMEspetaculoCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = nibs[0];
    }
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(QMEspetaculoCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    QMEspetaculo *espetaculo = _espetaculos[(NSUInteger) indexPath.row];
    [cell setEspetaculo:espetaculo];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1.0] CGColor];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static QMEspetaculoCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"QMEspetaculoCell" owner:self options:nil];
        sizingCell = nibs[0];
    });

    [self configureCell:sizingCell forIndexPath:indexPath];
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QMEspetaculo *espetaculo = _espetaculos[(NSUInteger) indexPath.row];
    [self performSegueWithIdentifier:@"espetaculoWebViewSegue" sender:espetaculo];
}

@end
