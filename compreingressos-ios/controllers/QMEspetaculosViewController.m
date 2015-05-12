//
//  QMEspetaculosViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMEspetaculosViewController.h"
#import "QMGenre.h"
#import "QMEspetaculosRequester.h"
#import "SVProgressHUD.h"
#import "QMEspetaculoCell.h"
#import "QMWebViewController.h"

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
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self requestEspetaculos];
    
    UINib *cellNib = [UINib nibWithNibName:@"QMEspetaculoCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"QMEspetaculoCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setGenre:(QMGenre *)genre {
    _genre = genre;
    self.navigationItem.title = genre.title;
}

- (void)requestEspetaculos {
    [SVProgressHUD show];
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
        [SVProgressHUD dismiss];
    } onFailBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
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
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QMEspetaculo *espetaculo = _espetaculos[(NSUInteger) indexPath.row];
    [self performSegueWithIdentifier:@"espetaculoWebViewSegue" sender:espetaculo];
}

@end
