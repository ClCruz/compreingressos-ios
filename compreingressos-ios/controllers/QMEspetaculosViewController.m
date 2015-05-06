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
    QMGenre *_genre;
    UICollectionView *_collectionView;
    NSArray *_espetaculos;
    CLLocation *_location;
}

@synthesize genre = _genre;
@synthesize collectionView = _collectionView;
@synthesize location = _location;

- (void)viewDidLoad {
    [super viewDidLoad];
    _espetaculos = [[NSMutableArray alloc] init];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self requestEspetaculos];
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
        NSNumber *latitude = [NSNumber numberWithDouble:_location.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:_location.coordinate.longitude];
        options[@"latitude"] = latitude;
        options[@"longitude"] = longitude;
    }
    [QMEspetaculosRequester requestEspetaculosWithOptions:options onCompleteBlock:^(NSArray *array, NSNumber *total) {
        _espetaculos = array;
        [_collectionView reloadData];
        [SVProgressHUD dismiss];
    }                                         onFailBlock:^(NSError *error) {
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMEspetaculoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"QMEspetaculoCell" forIndexPath:indexPath];
    QMEspetaculo *espetaculo = _espetaculos[(NSUInteger) indexPath.row];
    [cell setEspetaculo:espetaculo];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1.0] CGColor];
    // cell.backgroundColor = [UIColor whiteColor];
    // cell.layer.borderWidth = 1.0;
    // cell.layer.borderColor = [[UIColor blueColor] CGColor];
    // NSLog(@"   %@: (%f, %f)", espetaculo.titulo, cell.frame.size.width, cell.frame.size.height);
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMEspetaculo *espetaculo = _espetaculos[(NSUInteger) indexPath.row];
    CGSize size = [QMEspetaculoCell sizeForEspetaculo:espetaculo];
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QMEspetaculo *espetaculo = _espetaculos[(NSUInteger) indexPath.row];
    [self performSegueWithIdentifier:@"espetaculoWebViewSegue" sender:espetaculo];
}

@end
