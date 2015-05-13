//
//  QMHomeViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/16/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//


#import "JSBadgeView.h"
#import "SVProgressHUD.h"
#import "QMVisoresRequester.h"
#import "QMConstants.h"
#import "QMGenre.h"
#import "QMVisor.h"
#import "QMOrder.h"
#import "QMGenreCell.h"
#import "QMCarouselView.h"
#import "QMHomeViewController.h"
#import "QMWebViewController.h"
#import "QMEspetaculosViewController.h"
#import "QMEspetaculosGridHeaderView.h"
#import "QMOrderHistoryViewController.h"
#import "QMSearchViewController.h"
#import "QMBannerView.h"
#import "QMPushNotificationUtils.h"

//static NSString *const kCompreIngressosURL = @"http://186.237.201.132:81/compreingressos2/comprar/etapa1.php?apresentacao=61566&eventoDS=COSI%20FAN%20TUT%20TE";

static CGFloat kGenresMargin = 6.0f;

@interface QMHomeViewController ()

@end

@implementation QMHomeViewController {
    NSArray           *_visores;
    NSArray           *_genresJson;
    NSMutableArray    *_genres;
    QMCarouselView    *_carouselView;
    UIView            *_bottomView; // Última view da scrollview
    UIView            *_badgeContainer;
    JSBadgeView       *_badgeView;
    CLLocationManager *_locationManager;
    CLLocation        *_location;
    UIAlertView       *_gpsErrorAlertView;
    QMGenre           *_selectedGenre;
    BOOL              _segueLock;
    BOOL              _showBadgeOnViewDidAppear;
    BOOL              _hideBadgeOnViewDidAppear;
    
    IBOutlet UICollectionView   *_collectionView;
    IBOutlet UIImageView        *_background;
    IBOutlet UIScrollView       *_scrollView;
    IBOutlet UIBarButtonItem    *_orderHistoryButton;
    IBOutlet UIBarButtonItem    *_buttonForLogo;
    QMEspetaculosGridHeaderView *_carrosselVisores;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _genresJson = @[
                    @{@"title": @"Perto de Mim", @"icon_url": @"perto_de_mim.png", @"image_url": @"perto_de_mim_photo.png", @"search_term":@""},
                    @{@"title": @"Shows", @"icon_url": @"shows.png", @"image_url": @"shows_photo.png", @"search_term":@"Show"},
                    @{@"title": @"Clássicos", @"icon_url": @"classica.png", @"image_url": @"classica_photo.png", @"search_term":@"Classicos"},
                    @{@"title": @"Teatro", @"icon_url": @"teatro.png", @"image_url": @"teatro_photo.png", @"search_term":@"Teatros"},
                    @{@"title": @"Muito Mais", @"icon_url": @"muito_mais.png", @"image_url": @"muito_mais_photo.png", @"search_term":@""}
                 ];
    
    _visores = [[NSArray alloc] init];
    _genres = [[NSMutableArray alloc] init];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self configureCompreIngressosLogo];
    [self configureLocationManager];
    [self configureCarousel];
    [self configureOrderHistoryButton];
    [self configureSearchButton];
    [self parseGenres];
    [self scrollViewDirtyFix];
    [self requestData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clickedOnBanner:)
                                                 name:kOpenEspetaculoWebviewNotificationTag
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orderFinished:)
                                                 name:kOrderFinishedTag
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideBadge:)
                                                 name:kHideBadgeTag
                                               object:nil];
    
//    NSString *json = @"{\"number\":\"436464\",\"date\":\"sáb 28 nov\",\"total\":\"50,00\",\"espetaculo\":{\"titulo\":\"COSI FAN TUT TE\",\"endereco\":\"Praça Ramos de Azevedo, s/n - República - São Paulo, SP\",\"nome_teatro\":\"Theatro Municipal de São Paulo\",\"horario\":\"20h00\"},\"ingressos\":[{\"qrcode\":\"0054741128200000100146\",\"local\":\"SETOR 3 ANFITEATRO C-06\",\"type\":\"INTEIRA\",\"price\":\"50,00\",\"service_price\":\" 0,00\",\"total\":\"50,00\"}]}";
//    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error = nil;
//    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//
//    QMOrder *order = [[QMOrder alloc] initWithDictionary:jsonDictionary];
//    [QMOrder addOrderToHistory:order];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _segueLock = NO;
    _scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, kGenresMargin, 0.0);
    [_carouselView resetCaroselTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_showBadgeOnViewDidAppear) {
        _showBadgeOnViewDidAppear = NO;
        [_badgeView setBadgeText:@"! "];
        [self animateBadge];
    }
    if (_badgeContainer.alpha > 0.0 && _hideBadgeOnViewDidAppear) {
        _hideBadgeOnViewDidAppear = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _badgeContainer.alpha = 0.0;
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_locationManager stopUpdatingLocation];
    [_carouselView stopCaroselTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configureOrderHistoryButton {
    UIButton *orderHistoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 28.0, 29.0)];
    [orderHistoryButton setImage:[UIImage imageNamed:@"order_history_icon.png"] forState:UIControlStateNormal];
    [orderHistoryButton addTarget:self action:@selector(clickedOnOrderHistory:) forControlEvents:UIControlEventTouchUpInside];
    [_orderHistoryButton setCustomView:orderHistoryButton];
    
    _badgeContainer = [[UIView alloc] init];
    _badgeContainer.frame = CGRectSetOrigin(_badgeContainer.frame, CGPointMake(27.0, 2.0));
    _badgeContainer.frame = CGRectSetSize(_badgeContainer.frame, CGSizeMake(1,1));
    [orderHistoryButton addSubview:_badgeContainer];
    _badgeView = [[JSBadgeView alloc] initWithParentView:_badgeContainer alignment:JSBadgeViewAlignmentTopRight];
}

- (void)configureSearchButton {
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 28.0, 29.0)];
    [searchButton setImage:[UIImage imageNamed:@"search_icon.png"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(clickedOnSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItems = @[_orderHistoryButton, searchBarButton];
}

- (void)configureCompreIngressosLogo {
    UIImageView *compreIngressos = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ingressos.png"]];
    [_buttonForLogo setCustomView:compreIngressos];
    [self.navigationItem setTitle:nil];
}

- (void)configureLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100.0f;
}

- (void)parseGenres {
    for (int i=0; i<[_genresJson count]; i++) {
        NSDictionary *genreDict = _genresJson[i];
        QMGenre *genre = [[QMGenre alloc] initWithDictionary:genreDict];
        [_genres addObject:genre];
        [self showGenre:genre onIndex:i];
    }
}

- (void)showGenre:(QMGenre *)genre onIndex:(int)index {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat genreViewHeight = screenWidth * 0.3875f;
    QMGenreView *genreView = (QMGenreView *)[self loadNibNamed:@"QMGenreView"];
    [genreView setDelegate:self];
    [genreView setGenre: genre];
    genreView.frame = CGRectSetSize(genreView.frame, CGSizeMake(screenWidth, genreViewHeight));
    CGFloat y = CGRectGetHeightWithOffset(_bottomView.frame) + kGenresMargin;
    genreView.frame = CGRectSetOriginX(genreView.frame, 0.0f);
    genreView.frame = CGRectSetOriginY(genreView.frame, y);
    [_scrollView addSubview:genreView];
    _bottomView = genreView;
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _bottomView.frame.origin.y + _bottomView.frame.size.height)];
    //    [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //    [genreView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(genreView);
    //    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[genreView]|" options:0 metrics: 0 views:viewsDictionary]];
    //    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[genreView]|" options:0 metrics: 0 views:viewsDictionary]];
}

- (void)requestData {
    if ([self isConnected]) {
        if ([_visores count] == 0) { // só pede do server se não tiver pedido ainda
            [self requestVisores];
        }
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
        NSMutableArray *banners = [[NSMutableArray alloc] init];
        for (QMVisor *visor in _visores) {
            [banners addObject:[visor toBanner]];
        }
        [_carouselView setBanners:banners];
    } onFailBlock:^(NSError *error) {
    }];
}

/*  */
- (void)scrollViewDirtyFix {
    [_scrollView setContentOffset:CGPointMake(0.0, -64.0f) animated:YES];
}

- (void)openWebview:(UILocalNotification *)notification {
    NSString *url = notification.userInfo[@"url"];
    [self performSegueWithIdentifier:@"espetaculoWebViewSegue" sender:url];
}

- (void)configureCarousel {
    _carouselView = (QMCarouselView *)[self loadNibNamed:@"QMCarouselView"];
    [_carouselView prepareCarouselForRetina4:YES];
    [_scrollView addSubview:_carouselView];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat carouselHeight = screenWidth / 2.051f;
    _carouselView.frame = CGRectSetSize(_carouselView.frame, CGSizeMake(screenWidth, carouselHeight));
    _bottomView = _carouselView;
}

- (UIView *)loadNibNamed:(NSString *)name {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
    return nibs[0];
}

- (IBAction)clickedOnOrderHistory:(id)sender {
    [self performSegueWithIdentifier:@"orderHistorySegue" sender:nil];
}

- (void)clickedOnSearchButton:(id)sender {
    [self performSegueWithIdentifier:@"searchSegue" sender:nil];
}

- (void)clickedOnBanner:(UILocalNotification *)notification {
    NSString *url = notification.userInfo[@"url"];
    [self performSegueWithIdentifier:@"espetaculoWebViewSegue" sender:url];
}

- (void)animateBadge {
    [_badgeView layoutIfNeeded];
    [_badgeView layoutSubviews];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _badgeView.transform = CGAffineTransformScale(_badgeView.transform, 3, 3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _badgeView.transform = CGAffineTransformScale(_badgeView.transform, 0.3334, 0.3334);
        } completion:nil];
    }];
}

- (void)orderFinished:(UILocalNotification *)notification {
        _showBadgeOnViewDidAppear = YES;
}

- (void)hideBadge:(UILocalNotification *)notification {
    _hideBadgeOnViewDidAppear = YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[QMEspetaculosViewController class]]) {
        QMEspetaculosViewController *controller = segue.destinationViewController;
        [controller setGenre:_selectedGenre];
        [controller setLocation:_location];
    }
    else if ([segue.destinationViewController isKindOfClass:[QMWebViewController class]]) {
        QMWebViewController *controller = segue.destinationViewController;
        NSString *url = (NSString *)sender;
        [controller setUrl:url];
        [controller setIsZerothStep:YES];
    }
    else if ([segue.destinationViewController isKindOfClass:[QMSearchViewController class]]) {
        QMSearchViewController *controller = segue.destinationViewController;
    }
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

- (void)goToSearchResults {
    if (!_segueLock) {
        /*  Se o usuário permitir ou proibir o tokecompre de usar o gps esta callback tb será chamada. */
        [self performSegueWithIdentifier:@"espetaculosSegue" sender:nil];
        _segueLock = YES;
    }
}

- (void)checkLocationBeforeGoToResults {
    if (!_location || [self locationIsOld:_location]) {
        NSLog(@"location is old, fetching another one");
        [_locationManager startUpdatingLocation];
    } else {
        [self goToSearchResults];
    }
}

- (void)didSelectGenre:(QMGenre *)genre {
    _selectedGenre = genre;
    [self checkLocationBeforeGoToResults];
}

# pragma mark
# pragma mark - UICollectionView Datasource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    _carrosselVisores = [_collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                            withReuseIdentifier:@"QMEspetaculosGridHeaderView"
                                                                   forIndexPath:indexPath];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat carouselHeight = screenWidth / 1.684f;
    _carrosselVisores.frame = CGRectSetSize(_carrosselVisores.frame, CGSizeMake(screenWidth, carouselHeight));
    return _carrosselVisores;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 0;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(104.0, 86.0);
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat carouselHeight = screenWidth / 1.684f;
    return CGSizeMake(screenWidth, carouselHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedGenre = _genres[indexPath.row];
    [self checkLocationBeforeGoToResults];
    // [self goToSearchResults];
}


#pragma mark -
#pragma mark - Location Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    /* Vamos testar pegando a primeira localização que vier. Por dois motivos:
     1 - Nao precisamos de precisão absurda
     2 - Fica mais fácil controlar o fluxo, pois este método chama o goToSearchResults toda
     vez que um update é recebido. E se não pararmos o updatingLocation pode dar confusão */
    [_locationManager stopUpdatingLocation];
    _location = [locations lastObject];
    NSLog(@" fix -- latitude %+.6f, longitude %+.6f\n",
          _location.coordinate.latitude,
          _location.coordinate.longitude);
    [self goToSearchResults];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code ==  kCLErrorDenied) {
        NSString *message = @"Você não autorizou o tokEcompre para utilizar sua localização atual.";
        [self showGpsErrorWithMessage:message];
    } else {
        NSString *message = @"Não foi possível pegar sua localização atual.";
        [self showGpsErrorWithMessage:message];
    }
    
    NSLog(@"  -- Location failed");
}

- (void)showGpsErrorWithMessage:(NSString *)message {
    _gpsErrorAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"Fechar"
                                         otherButtonTitles:nil];
    [_gpsErrorAlertView show];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"  -- didChangeAuthorizationStatus: %i", status);
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusAuthorized) {
        if (status == kCLAuthorizationStatusAuthorized) {
            /* Se o gps está permitido, então não precisa chamar o goToSearchResults pois
             * a callback didUpdateLocations será chamada */
            NSLog(@"  -- permitiu o gps");
        }
        if (status == kCLAuthorizationStatusDenied) {
            /* Neste ponto é necessário chamar o goToSearchResults porque na primeira vez q o aplicativo
             * é executado e a msg de permissão do gps aparece, se o usuário negar a permissão, a callback
             * didFailWithError não será chamada. */
            NSLog(@"  -- nao permitiu o gps");
            [self goToSearchResults];
        }
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [[UIApplication sharedApplication] sendAction:@selector(requestAlwaysAuthorization)
                                                       to:_locationManager
                                                     from:self
                                                 forEvent:nil];
        }
        [SVProgressHUD showErrorWithStatus:@"Você não autorizou o tokEcompre para utilizar sua localização atual"];
    }
}

- (BOOL)locationIsOld:(CLLocation *)aLocation {
    //    NSDate* eventDate = aLocation.timestamp;
    //    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //    NSLog(@"     elapsed %f, %f", howRecent, [eventDate timeIntervalSince1970]);
    return true;
}

@end
