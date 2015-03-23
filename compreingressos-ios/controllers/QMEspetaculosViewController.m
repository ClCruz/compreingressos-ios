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
    [self requestEspetaculos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setGenre:(QMGenre *)genre {
    _genre = genre;
    
}

- (void)requestEspetaculos {
    [SVProgressHUD show];
    NSDictionary *options = @{@"genre": _genre.title};
    [QMEspetaculosRequester requestEspetaculosWithOptions:options onCompleteBlock:^(NSArray *array) {
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

@end
