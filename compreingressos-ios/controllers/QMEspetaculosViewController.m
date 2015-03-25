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
}

@synthesize genre = _genre;
@synthesize collectionView = _collectionView;

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
    if (![_genre.title isEqualToString:@"Perto de Mim"]) {
        NSString *genreTitle = _genre.title;
        if ([_genre.title isEqualToString:@"Shows"]) {
            genreTitle = @"Show";
        }
        options[@"genero"] = genreTitle;
    }
    [QMEspetaculosRequester requestEspetaculosWithOptions:options forGenre:_genre onCompleteBlock:^(NSArray *array, NSNumber *total) {
        _espetaculos = array;
        [_collectionView reloadData];
        [SVProgressHUD dismiss];
    } onFailBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    return 1.0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMEspetaculoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"QMEspetaculoCell" forIndexPath:indexPath];
    QMEspetaculo *espetaculo = _espetaculos[indexPath.row];
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
    QMEspetaculo *espetaculo = _espetaculos[indexPath.row];
    CGSize size = [QMEspetaculoCell sizeForEspetaculo:espetaculo];
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QMEspetaculo *espetaculo = _espetaculos[indexPath.row];
    [self performSegueWithIdentifier:@"espetaculoWebViewSegue" sender:espetaculo];
}

@end
