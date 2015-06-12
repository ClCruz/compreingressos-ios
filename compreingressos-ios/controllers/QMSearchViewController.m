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
#import <Google/Analytics.h>

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
    [self configureCollectionView];
    _espetaculos = [[NSMutableArray alloc] init];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.titleView = _searchBar;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Busca"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureSearchBar {
    _searchBar = [[UISearchBar alloc] init];
    [_searchBar setPlaceholder:@"Busque eventos"];
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    [_searchBar becomeFirstResponder];
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

- (void)requestData {
    if ([self isConnected]) {
        [SVProgressHUD show];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        options[@"keywords"] = _keywords;
        [QMEspetaculosRequester requestEspetaculosWithOptions:options onCompleteBlock:^(NSArray *array, NSNumber *total) {
            _espetaculos = array;
            [_collectionView reloadData];
            if ([_espetaculos count] == 0) {
                [SVProgressHUD showErrorWithStatus:@"Não foi encontrado nenhum resultado..."];
            } else {
                [SVProgressHUD dismiss];
            }
        } onFailBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
    } else {
        [self showNotConnectedError];
    }
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
    [self requestData];
}

@end
