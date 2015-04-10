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
#import "QMConstants.h"
#import "QMCarouselView.h"
#import "QMVisor.h"
#import "QMOrder.h"

//static NSString *const kCompreIngressosURL = @"http://186.237.201.132:81/compreingressos2/comprar/etapa1.php?apresentacao=61566&eventoDS=COSI%20FAN%20TUT%20TE";

static CGFloat kGenresMargin = 6.0f;

@interface QMHomeViewController ()

@end

@implementation QMHomeViewController {
    NSArray *_visores;
    NSArray *_genresJson;
    NSMutableArray *_genres;
    IBOutlet UICollectionView *_collectionView;
    IBOutlet UIImageView *_background;
    QMEspetaculosGridHeaderView *_carrosselVisores;
    QMCarouselView *_carouselView;
    UIView *_bottomView; // Última view da scrollview
    CLLocationManager *_locationManager;
    CLLocation *_location;
    UIAlertView *_gpsErrorAlertView;
    BOOL _segueLock;
    QMGenre *_selectedGenre;
    IBOutlet UIScrollView *_scrollView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _genresJson = @[
                    @{@"title": @"Perto de Mim", @"icon_url": @"perto_de_mim.png", @"image_url": @"perto_de_mim.png", @"search_term":@""},
                    @{@"title": @"Shows", @"icon_url": @"shows.png", @"image_url": @"shows.png", @"search_term":@"show"},
                    @{@"title": @"Clássicos", @"icon_url": @"classica.png", @"image_url": @"classica.png", @"search_term":@"Concertos Sinfônicos"},
                    @{@"title": @"Teatro", @"icon_url": @"teatro.png", @"image_url": @"teatro.png", @"search_term":@"Teatro"},
                    @{@"title": @"Muito Mais", @"icon_url": @"muito_mais.png", @"image_url": @"muito_mais.png", @"search_term":@"Todos os gêneros"}
                 ];
    _visores = [[NSArray alloc] init];
    _genres = [[NSMutableArray alloc] init];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
//    _collectionView.backgroundColor = UIColorFromRGB(0xefeff4);
//    _collectionView.backgroundColor = [UIColor clearColor];
    UIImageView *compreIngressos = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ingressos.png"]];
    self.navigationItem.titleView = compreIngressos;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openWebview:)
                                                 name:kOpenEspetaculoWebviewNotificationTag
                                               object:nil];

    [self configureLocationManager];
    [self configureCarousel];
    [self parseGenres];
    [self requestData];
    
//    NSString *json = @"{\"order\":{\"number\":\"436448\",\"date\":\"sáb 28 nov\",\"total\":\"50,00\",\"espetaculo\":{\"titulo\":\"COSI FAN TUT TE 2\",\"endereco\":\"Praça Ramos de Azevedo, s/n - República - São Paulo, SP\",\"teatro\":\"Theatro Municipal de São Paulo\",\"horario\":\"20h00\"},\"ingressos\":[{\"qrcode\":\"xx0054721128200000100133\",\"local\":\"SETOR 3 BALCÃO SIMPLES D-44\",\"type\":\"INTEIRA\",\"price\":\"50,00\",\"service_price\":\" 0,00\",\"total\":\"50,00\"}]}}";
//    
//    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error = nil;
//    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _segueLock = NO;
    _scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, kGenresMargin, 0.0);
    NSArray *orderHistory = [QMOrder orderHistory];
    NSLog(@"history count: %i", (int)[orderHistory count]);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    CGFloat topMargin = index == 0 ? 0.0f : kGenresMargin;
    CGFloat y = CGRectGetHeightWithOffset(_bottomView.frame) + topMargin;
    genreView.frame = CGRectSetOriginX(genreView.frame, 0.0f);
    genreView.frame = CGRectSetOriginY(genreView.frame, y);
    [_scrollView addSubview:genreView];
    _bottomView = genreView;
    [_scrollView setContentSize:CGSizeMake(screenWidth, _bottomView.frame.origin.y + _bottomView.frame.size.height)];
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
        NSMutableArray *banners = [[NSMutableArray alloc] init];
        for (QMVisor *visor in _visores) {
            [banners addObject:[visor toBanner]];
        }
        [_carouselView setBanners:banners];
        [SVProgressHUD dismiss];
    } onFailBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
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
    CGFloat carouselHeight = screenWidth / 1.684f;
    _carouselView.frame = CGRectSetSize(_carouselView.frame, CGSizeMake(screenWidth, carouselHeight));
    _bottomView = _carouselView;
}

- (UIView *)loadNibNamed:(NSString *)name {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
    return nibs[0];
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
