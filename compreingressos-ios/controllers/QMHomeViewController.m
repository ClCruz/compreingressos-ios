//
//  QMHomeViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/16/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMHomeViewController.h"
#import "QMGenreCell.h"
#import "QMWebViewController.h"
#import "QMVisoresRequester.h"
#import "SVProgressHUD.h"
#import "QMEspetaculosGridHeaderView.h"
#import "QMGenre.h"
#import "QMEspetaculosViewController.h"

//static NSString *const kCompreIngressosURL = @"http://186.237.201.132:81/compreingressos2/comprar/etapa1.php?apresentacao=61566&eventoDS=COSI%20FAN%20TUT%20TE";
static NSString *const kCompreIngressosURL = @"http://www.compreingressos.com/espetaculos";

@interface QMHomeViewController ()

@end

@implementation QMHomeViewController {
    NSArray *_visores;
    NSArray *_genresJson;
    NSMutableArray *_genres;
    IBOutlet UICollectionView *_collectionView;
    QMEspetaculosGridHeaderView *_carrosselVisores;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _genresJson = @[
                    @{@"title": @"Perto de Mim", @"icon_url": @"", @"image_url": @""},
                    @{@"title": @"Comédia", @"icon_url": @"", @"image_url": @""},
                    @{@"title": @"Shows", @"icon_url": @"", @"image_url": @""},
                    @{@"title": @"Drama", @"icon_url": @"", @"image_url": @""}
                 ];
    _visores = [[NSArray alloc] init];
    _genres = [[NSMutableArray alloc] init];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = UIColorFromRGB(0xefeff4);
    [self parseGenres];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)parseGenres {
    for (NSDictionary *genreDict in _genresJson) {
        QMGenre *genre = [[QMGenre alloc] initWithDictionary:genreDict];
        [_genres addObject:genre];
    }
}
- (void)requestData {
    if ([self isConnected]) {
        [SVProgressHUD show];
        if ([_visores count] == 0) { // só pede do server se não tiver pedido ainda
            [self requestVisores];
        }
//        if ([_espetaculos count] == 0) { // só pede do server se não tiver pedido ainda
//            [self requestEspetaculos];
//        }
    } else {
//        [self showNotConnectedErrorWithoutCover];
    }
}

- (BOOL)isConnected {
//    if([QMRequester offlineMode]) return YES;
//    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//    if(networkStatus == ReachableViaWWAN || networkStatus == ReachableViaWiFi) {
//        return YES;
//    } else {
//        return NO;
//    }
    return YES;
}

- (void)requestVisores {
    [QMVisoresRequester requestVisoresOnCompleteBlock:^(NSArray *array) {
        _visores = array;
        [_carrosselVisores setVisores:_visores];
        [SVProgressHUD dismiss];
    } onFailBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QMEspetaculosViewController *controller = segue.destinationViewController;
    QMGenre *genre = sender;
    [controller setGenre:genre];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    _carrosselVisores = [_collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                            withReuseIdentifier:@"QMEspetaculosGridHeaderView"
                                                                   forIndexPath:indexPath];
    return _carrosselVisores;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_genres count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1.0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMGenreCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"QMGenreCell" forIndexPath:indexPath];
    QMGenre *genre = _genres[indexPath.row];
    [cell setGenre:genre];
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    QMGenre *genre = _genres[indexPath.row];
//    CGSize size = [QMEspetaculoCell sizeForEspetaculo:espetaculo];
//    return size;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QMGenre *genre = _genres[indexPath.row];
    [self performSegueWithIdentifier:@"espetaculosSegue" sender:genre];
}

@end
