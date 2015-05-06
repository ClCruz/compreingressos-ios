//
//  QMSearchViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 5/5/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMSearchViewController.h"
#import "QMEspetaculoCell.h"
#import "SVProgressHUD.h"
#import "QMEspetaculosRequester.h"
#import "QMWebViewController.h"

@interface QMSearchViewController ()

@end

@implementation QMSearchViewController {
@private
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UICollectionView *_collectionView;
    NSArray *_espetaculos;
    NSString *_keywords;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSearchBar];
    _espetaculos = [[NSMutableArray alloc] init];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
}

- (void)configureSearchBar {
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    [_searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)search {
    [SVProgressHUD show];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    options[@"keywords"] = _keywords;
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

#pragma mark -
#pragma mark - Search Bar Methods

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    [_searchBar setShowsCancelButton:YES animated:YES];
//    return YES;
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [_searchBar resignFirstResponder];
//    [_searchBar setShowsCancelButton:NO animated:YES];
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
    _keywords = searchBar.text;
    [self search];
}

@end
