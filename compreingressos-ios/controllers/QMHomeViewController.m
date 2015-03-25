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
    CLLocationManager *_locationManager;
    CLLocation *_location;
    UIAlertView *_gpsErrorAlertView;
    BOOL _segueLock;
    QMGenre *_selectedGenre;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _genresJson = @[
                    @{@"title": @"Perto de Mim", @"icon_url": @"perto_de_mim.png", @"image_url": @"perto_de_min_image.png"},
                    @{@"title": @"Concertos Sinfônicos", @"icon_url": @"concerto_sinfonico.png", @"image_url": @"concertos_sinfonicos_image.png"},
                    @{@"title": @"Comédia", @"icon_url": @"comedia.png", @"image_url": @"comedia_image.png"},
                    @{@"title": @"Shows", @"icon_url": @"shows.png", @"image_url": @"shows_image.png"},
                    @{@"title": @"Infantil", @"icon_url": @"infantil.png", @"image_url": @"infantil_image.png"},
                    @{@"title": @"Drama", @"icon_url": @"drama.png", @"image_url": @"drama_image.png"},
                    @{@"title": @"Stand-Up", @"icon_url": @"stand_up.png", @"image_url": @"stand_up_image.png"},
                    @{@"title": @"Musical", @"icon_url": @"musical.png", @"image_url": @"musical_image.png"},
                    @{@"title": @"Ópera", @"icon_url": @"opera.png", @"image_url": @"opera_image.png"},
                    @{@"title": @"Romance", @"icon_url": @"romance.png", @"image_url": @"romance_image.png"},
// @{@"title": @"Espírita", @"icon_url": @"espirita.png", @"image_url": @"espirita_image.png"},
                    @{@"title": @"Musical Infantil", @"icon_url": @"musical_infantil.png", @"image_url": @"musical_infantil_image.png"},
                    @{@"title": @"Comédia Musical", @"icon_url": @"comedia_musical.png", @"image_url": @"comedia_musical_image.png"},
                    @{@"title": @"Dança", @"icon_url": @"danca.png", @"image_url": @"danca_image.png"},
                    @{@"title": @"Comédia Romântica", @"icon_url": @"comedia_romantica.png", @"image_url": @"comedia_romantica_image.png"},
                    @{@"title": @"Comédia Dramática", @"icon_url": @"comedia_dramatica.png", @"image_url": @"comedia_dramatica_image.png"},
                    @{@"title": @"Suspense", @"icon_url": @"suspense.png", @"image_url": @"suspense_image.png"},
                    @{@"title": @"Comédia Perversa", @"icon_url": @"comedia_perversa.png", @"image_url": @"comedia_perversa_image.png"},
                    @{@"title": @"Música", @"icon_url": @"musica.png", @"image_url": @"musica_image.png"},
                    @{@"title": @"Circo", @"icon_url": @"circo.png", @"image_url": @"circo_image.png"}
                 ];
    _visores = [[NSArray alloc] init];
    _genres = [[NSMutableArray alloc] init];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = UIColorFromRGB(0xefeff4);
    UIImageView *compreIngressos = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ingressos.png"]];
    self.navigationItem.titleView = compreIngressos;
//    [self configureLocationManager];
    [self parseGenres];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _segueLock = NO;
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
    [controller setGenre:_selectedGenre];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(104.0, 86.0);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedGenre = _genres[indexPath.row];
    // [self checkLocationBeforeGoToResults];
    [self goToSearchResults];
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
