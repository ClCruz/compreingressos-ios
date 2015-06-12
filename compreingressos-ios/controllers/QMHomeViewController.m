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
#import "QMGenreCell.h"
#import "QMCarouselView.h"
#import "QMHomeViewController.h"
#import "QMWebViewController.h"
#import "QMEspetaculosViewController.h"
#import <Google/Analytics.h>

@interface QMHomeViewController ()

@end

@implementation QMHomeViewController {
    NSArray           *_visores;
    NSArray           *_genresJson;
    NSMutableArray    *_genres;
    QMCarouselView    *_carouselView;
    UIView            *_badgeContainer;
    JSBadgeView       *_badgeView;
    CLLocationManager *_locationManager;
    CLLocation        *_location;
    UIAlertView       *_gpsErrorAlertView;
    UIAlertView       *_requestGpsAlertView;
    QMGenre           *_selectedGenre;
    BOOL               _segueLock;
    BOOL               _showBadgeOnViewDidAppear;
    BOOL               _hideBadgeOnViewDidAppear;
    NSTimer           *_clickOnGenreTimer;

    IBOutlet UIBarButtonItem    *_orderHistoryButton;
    IBOutlet UIBarButtonItem    *_buttonForLogo;
    IBOutlet UITableView        *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _genresJson = @[
                    @{@"title": @"Perto de Mim", @"icon_url": @"perto_de_mim.png", @"image_url": @"perto_de_mim_photo.png", @"search_term": @""},
                    @{@"title": @"Shows",        @"icon_url": @"shows.png",        @"image_url": @"shows_photo.png",        @"search_term": @"Show"},
                    @{@"title": @"Clássicos",    @"icon_url": @"classica.png",     @"image_url": @"classica_photo.png",     @"search_term": @"Classicos"},
                    @{@"title": @"Teatro",       @"icon_url": @"teatro.png",       @"image_url": @"teatro_photo.png",       @"search_term": @"Teatros"},
                    @{@"title": @"Muito Mais",   @"icon_url": @"muito_mais.png",   @"image_url": @"muito_mais_photo.png",   @"search_term": @""}
                 ];
    
    _visores = [[NSArray alloc] init];
    _genres = [[NSMutableArray alloc] init];

    [self configureTableView];
    [self configureCompreIngressosLogo];
    [self configureLocationManager];
    [self configureOrderHistoryButton];
    [self configureSearchButton];
    [self parseGenres];
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
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)configureTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;

    /* Registrando nib QMEspetaculoCell que está fora do storyboard na collecionView */
    UINib *cellNib = [UINib nibWithNibName:@"QMCarouselView" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"QMCarouselView"];

    [_tableView setContentInset:UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _segueLock = NO;
    // _scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, kGenresMargin, 0.0);
    [_carouselView resetCaroselTimer];
    [self stopClickOnGenreTimer];
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
    [SVProgressHUD dismiss];
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
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    _locationManager.distanceFilter = 500.0f;
}

- (void)parseGenres {
    for (int i=0; i<[_genresJson count]; i++) {
        NSDictionary *genreDict = _genresJson[(NSUInteger) i];
        QMGenre *genre = [[QMGenre alloc] initWithDictionary:genreDict];
        [_genres addObject:genre];
    }
}

- (void)requestData {
    if ([self isConnected]) {
        if ([_visores count] == 0) { // só pede do server se não tiver pedido ainda
            [self requestVisores];
        }
    } else {
        [self showNotConnectedError];
    }
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

- (BOOL)choosedNearbyMe { /* Escolheu Perto de Mim */
    return [_selectedGenre.title isEqualToString:((QMGenre *)_genres[0]).title];
}

- (BOOL)choosedMuchMore { /* Escolheu Muito Mais */
    return _selectedGenre == [_genres lastObject];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[QMEspetaculosViewController class]]) {
        QMEspetaculosViewController *controller = segue.destinationViewController;
        [controller setGenre:_selectedGenre];
        if (![self choosedMuchMore]) { /* Perto de mim não envia location */
            [controller setLocation:_location];
        }
        _selectedGenre = nil;
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

- (void)goToEspetaculos {
    if (!_segueLock) {
        /*  Se o usuário permitir ou proibir o tokecompre de usar o gps esta callback tb será chamada. */
        [self performSegueWithIdentifier:@"espetaculosSegue" sender:nil];
        _segueLock = YES;
    }
}

- (void)checkLocationBeforeGoToEspetaculos {
    if (!_location || [self locationIsOld:_location]) {
        NSLog(@"location is old, fetching another one");
        [_locationManager startUpdatingLocation];
        [self startClickOnGenreTimerIfNeeded];
    } else {
        [self goToEspetaculos];
    }
}

/* Caso o gps não retorne nada em 2s, vamos prosseguir sem a
* localização */
- (void)startClickOnGenreTimerIfNeeded {
    if (!_clickOnGenreTimer) {
        [SVProgressHUD showWithStatus:@"Aguardando GPS"];
        _clickOnGenreTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:2]
                                                      interval:0
                                                        target:self
                                                      selector:@selector(clickOnGenreTimerTimeout)
                                                      userInfo:nil
                                                       repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_clickOnGenreTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)clickOnGenreTimerTimeout {
//    if (_location is )
    _clickOnGenreTimer = nil;
    [self goToEspetaculos];
}

- (void)stopClickOnGenreTimer {
    if (_clickOnGenreTimer) {
        [_clickOnGenreTimer invalidate];
        _clickOnGenreTimer = nil;
        [SVProgressHUD dismiss];
    }
}

- (void)didSelectGenre:(QMGenre *)genre {
    _selectedGenre = genre;
    /* Muito Mais mostra direto sem precisar do gps */
    if ([self choosedMuchMore]) {
        [self goToEspetaculos];
    } else {
        [self checkLocationBeforeGoToEspetaculos];
    }
}


# pragma mark
# pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [_genres count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        _carouselView = [tableView dequeueReusableCellWithIdentifier:@"QMCarouselView" forIndexPath:indexPath];
        [_carouselView prepareCarouselForRetina4:YES];
        cell = _carouselView;
    } else {
        QMGenreCell *genreCell = [tableView dequeueReusableCellWithIdentifier:@"QMGenreCell" forIndexPath:indexPath];
        QMGenre *genre = _genres[(NSUInteger) indexPath.row];
        [genreCell setGenre:genre];
        if ([_genres count] - 1 == indexPath.row) {
            [genreCell.separator setHidden:YES];
        }
        cell = genreCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat carouselHeight = screenWidth / 1.8f;
        return carouselHeight;
    } else {
        return kGenreCellHeight / 320.0f * [UIScreen mainScreen].bounds.size.width;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        QMGenre *genre = _genres[(NSUInteger) indexPath.row];
        [self didSelectGenre:genre];
    }
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
    [self goToEspetaculos];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code ==  kCLErrorDenied) {
        /* Depois que o usuário negou o gps, cai aqui toda vez que pedir uma localização */
        if (_selectedGenre) {
            if ([self choosedNearbyMe]) {
                [self askToRequireGps];

            } else {
                [self goToEspetaculos];
            }
        }
    } else {
        NSString *message = @"Não foi possível pegar sua localização atual.";
//        [self showGpsErrorWithMessage:message];
    }

    NSLog(@"  -- Location failed");
}

- (void)askToRequireGps {
    [self stopClickOnGenreTimer];
    _requestGpsAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                      message:@"Deseja permitir ao app COMPREINGRESSOS acessar sua posição de gps?"
                                                     delegate:self
                                            cancelButtonTitle:@"Não"
                                            otherButtonTitles:@"Sim", nil];
    [_requestGpsAlertView show];
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
            NSLog(@"  -- nao permitiu o gps");

            /* ------------------------------------------------------------- */
            /* Este seria o ponto de mostrar um dialog e perguntar novamente */
            /* se o usuário deseja ligar o gps                               */
            /* ------------------------------------------------------------- */

            /* Vamos chegar se o usuário clicou em algum gênero. Se não clicou
            *  então o usuário acabou de abrir o app. */
            if (_selectedGenre) {
                [self goToEspetaculos];
            }
        }
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        [self requestLocationAuthorization];
    }
}

- (void)requestLocationAuthorization {
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
}

- (BOOL)locationIsOld:(CLLocation *)aLocation {
    //    NSDate* eventDate = aLocation.timestamp;
    //    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //    NSLog(@"     elapsed %f, %f", howRecent, [eventDate timeIntervalSince1970]);
    return true;
}


#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    if (alertView == _requestGpsAlertView) {
        if (buttonIndex == 1) { /* Sim */
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:settingsURL];
            } else {
                UIAlertView *io7message = [[UIAlertView alloc] initWithTitle:nil message:@"Você pode habilitar o gps para o COMPREINGRESSOS em Ajustes->Privacidade->Localização" delegate:self cancelButtonTitle:@"Fechar" otherButtonTitles:nil, nil];
                [io7message show];
            }

        }
    }
}


@end
