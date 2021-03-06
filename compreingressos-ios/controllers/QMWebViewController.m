//
//  QMWebViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/17/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMWebViewController.h"
#import "SVProgressHUD.h"
#import "QMGenre.h"
#import "QMEspetaculo.h"
#import "QMOrder.h"
#import "QMRequester.h"
#import "QMConstants.h"
#import "NSHTTPCookieStorage+QMStorage.h"
#import "compreingressos-ios-Prefix.pch"
#import "QMPushNotificationUtils.h"
#import "QMZoomTutorialView.h"
#import "QMUser.h"
#import "QMPaymentFinalizationViewController.h"
#import "QMTrackPurchasesRequester.h"
#import "QMException.h"
#import <Google/Analytics.h>

static NSNumber *defaultWebViewBottomSpacing = nil;

@interface QMWebViewController () {
    UIWebView                   *_webview;
    NSString                    *_url;
    NSString                    *_promoCode;
    QMGenre                     *_genre;
    QMEspetaculo                *_espetaculo;
    QMZoomTutorialView          *_tutorialView;
    BOOL                         _firstTimeLoad;
    BOOL                         _isZerothStep;
    BOOL                         _isModal;
    IBOutlet UIView             *_statusBarBg;
    IBOutlet UIButton           *_nativeButton;
    IBOutlet UIView             *_nativeButtonContainer;
    IBOutlet NSLayoutConstraint *_webviewBottomSpacing;
}

@end

@implementation QMWebViewController

@synthesize webview      = _webview;
@synthesize url          = _url;
@synthesize promoCode    = _promoCode;
@synthesize genre        = _genre;
@synthesize espetaculo   = _espetaculo;
@synthesize isZerothStep = _isZerothStep;
@synthesize isModal      = _isModal;

- (void)viewDidLoad {
    [super viewDidLoad];
    _webview.delegate = self;
    _firstTimeLoad = YES;
    _nativeButtonContainer.alpha = 0.0;
    [_nativeButtonContainer setBackgroundColor:UIColorFromRGB(kCompreIngressosDefaultRedColor)];
    if ([self isLastStep]) {
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar" style:UIBarButtonItemStyleDone target:self action:@selector(clickedOnCloseButton)];
        self.navigationItem.rightBarButtonItem = closeButton;
    }
    
    if ([self isFifthStep:_url]) {
        [self removeLoginControllerFromQueue];
    }
    
    /* Armazenando o valor do espaçamento inferior da webview. Será utilizado 
       Quando for necessário esconder o botão. */
    if (!defaultWebViewBottomSpacing) {
        defaultWebViewBottomSpacing = @(_webviewBottomSpacing.constant);
    }

    [self injectUserCookieIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_firstTimeLoad) {
        [self openUrl];
    }
    self.navigationItem.title = [self titleForStep];
    if ([self isShowNativeButton]) {
        _nativeButtonContainer.alpha = 1.0;
        if ([self isSixthStep:_url]) {
            [_nativeButton setTitle:@"Pagar" forState:UIControlStateNormal];
        }
        _webviewBottomSpacing.constant = [defaultWebViewBottomSpacing floatValue];
    } else {
        _webviewBottomSpacing.constant = 0.0;
    }
    [_webview layoutIfNeeded];
    
    [self configureModalIfNeeded];
    [self printCookies];
    [self saveUserHashAndPhpSession];

    NSString *titleForAnalytics = [self titleForStepForAnalytics:YES];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:titleForAnalytics];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)injectUserCookieIfNeeded {
    QMUser *user = [QMUser sharedInstance];
    if (user.userHash && user.phpSession) {
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSDictionary *properties;
        properties = @{
                NSHTTPCookieName: @"user",
                NSHTTPCookieValue: user.userHash,
                NSHTTPCookiePath: @"/comprar",
                NSHTTPCookieDomain: @"compra.compreingressos.com",
                NSHTTPCookieSecure: @"0"
        };
        NSHTTPCookie *userCookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        [cookieJar setCookie:userCookie];

        properties = @{
                NSHTTPCookieName: @"PHPSESSID",
                NSHTTPCookieValue: user.phpSession,
                NSHTTPCookiePath: @"/",
                NSHTTPCookieDomain: @"compra.compreingressos.com",
                NSHTTPCookieSecure: @"0"
        };
        NSHTTPCookie *sessionCookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        [cookieJar setCookie:sessionCookie];
    }
}

- (void)showTutorialIfNeeded {
    if ([self neverShowedTutorialBefore]) {
        [self showTutorial];
    }
}

- (BOOL)neverShowedTutorialBefore {
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"zoomTutorial"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"zoomTutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

- (void)showTutorial {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"QMZoomTutorialView" owner:nil options:nil];
    _tutorialView = nibs[0];
    [_tutorialView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_tutorialView];

    NSLayoutConstraint *width =[NSLayoutConstraint
                                constraintWithItem:_tutorialView
                                attribute:NSLayoutAttributeWidth
                                relatedBy:0
                                toItem:self.view
                                attribute:NSLayoutAttributeWidth
                                multiplier:1.0
                                constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint
                                 constraintWithItem:_tutorialView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:0
                                 toItem:self.view
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:1.0
                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:_tutorialView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:_tutorialView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];

    [self.view addConstraints:@[width, height, top, leading]];
    
    UITapGestureRecognizer *tutorialTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTutorial)];
    [tutorialTap setNumberOfTapsRequired:1];
    [_tutorialView addGestureRecognizer:tutorialTap];
}

- (void)didTapOnTutorial {
    [UIView animateWithDuration:0.3 animations:^{
        _tutorialView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_tutorialView removeFromSuperview];
    }];
}

- (void)printCookies {
    NSLog(@"======================================================");
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
        NSLog(@"    - %@", cookie.value);
    }
    NSLog(@"======================================================");
}

- (void)saveUserHashAndPhpSession {
    QMUser *user = [QMUser sharedInstance];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        if ([cookie.name isEqualToString:@"user"]) {
            [user setUserHash:cookie.value];
        }
        if ([cookie.name isEqualToString:@"PHPSESSID"]) {
            [user setPhpSession:cookie.value];
        }
    }
    [user save];
}

- (void)removeLoginControllerFromQueue {
    NSUInteger count = [self.navigationController.viewControllers count];
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [controllers removeObjectAtIndex:count - 2];
    [self.navigationController setViewControllers:controllers];
}

- (BOOL)isShowNativeButton {
    return [self isSecondStep:_url] || [self isThirdStep:_url] || [self isFifthStep:_url] || [self isSixthStep:_url];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_firstTimeLoad) {
        [SVProgressHUD show];
    }
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] save];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (_isModal) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)configureModalIfNeeded {
    if (!_isModal) return;
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar" style:UIBarButtonItemStyleDone target:self action:@selector(clickedOnCloseButton:)];
    [closeButton setTintColor:UIColorFromRGB(kCompreIngressosDefaultRedColor)];
    self.navigationItem.rightBarButtonItem = closeButton;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self configureCompreIngressosLogo];
}

- (void)configureCompreIngressosLogo {
    UIImageView *compreIngressos = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ingressos.png"]];
    UIBarButtonItem *buttonForLogo = [[UIBarButtonItem alloc] initWithTitle:@"logo" style:UIBarButtonItemStyleDone target:nil action:nil];
    [buttonForLogo setCustomView:compreIngressos];
    self.navigationItem.leftBarButtonItem = buttonForLogo;
}

- (void)clickedOnCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEspetaculo:(QMEspetaculo *)espetaculo {
    _espetaculo = espetaculo;
    _url = _espetaculo.url;
}

- (void)openUrl {
    [self requestData];
}

- (void)requestData {
    if ([self isConnected]) {
        /* Se não recebemos uma url, estamos no fluxo inicial, iremos montar a url a partir do espetáculo */
        if (_url && [_url rangeOfString:@"app=tokecompre"].length == 0) {
            _url = [QMRequester addQueryStringParamenter:@"app" withValue:@"tokecompre" toUrl:_url];
        }

        NSURL *url = [NSURL URLWithString:[QMRequester addVersionToUrl:_url]];
        NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
        [_webview loadRequest:requestURL];

        /* Vamos esconder a webview em todas as páginas menos no detalhe do espetáculo.
        *  Pois o detalhe do espetáculo demora muito para carregar causando impressão
        *  de maior lentidão que o site. */
        if (![self isFirstStep:_url]) {
            _webview.alpha = 0.0;
        }
    } else {
        __weak typeof(self) weakSelf = self;
       [self showNotConnectedErrorOnRetry:^{
           [SVProgressHUD show];
           [weakSelf requestData];
       }];
    }
}

- (void)clickedOnCloseButton {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [CATransaction commit];
}

- (NSString *)titleForStep {
    return [self titleForStepForAnalytics:NO];
}


- (NSString *)titleForStepForAnalytics:(BOOL)analytics {
    NSString *title = @"";
    if (_isZerothStep) {
        title = @"Destaque";
    }
    else if ([self isFirstStep:_url]) {
        title = @"Espetáculo";
        if (_espetaculo && !analytics) {
            title = _espetaculo.titulo;
        }
    }
    else if ([self isSecondStep:_url]) {
        title = @"Seu Ingresso";
    }
    else if ([self isThirdStep:_url]) {
        title = @"Tipo do Ingresso";
    }
    else if ([self isFourthStep:_url]) {
        title = @"Login";
    }
    else if ([self isFifthStep:_url]) {
        title = @"Confirmação";
    }
    else if ([self isSixthStep:_url]) {
        title = @"Pagamento";
    }

    /* A partir daqui, não será mostrado para o usuário, porém
     * vamos gerar os títulos para fins de analytics */
    else if ([self isSeventhStep:_url]) {
        title = @"Finalização Pagamento";
    }
    else if ([self isAssinaturas:_url]) {
        title = @"Assinaturas";
    }

    if (analytics) {
        title = [NSString stringWithFormat:@"[webview] %@", title];
    }

    return title;
}


- (void)configureNextViewBackButtonWithTitle:(NSString *)title {
    UIBarButtonItem *nextViewBackButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:nil
                                                                          action:nil];
    [self.navigationItem setBackBarButtonItem:nextViewBackButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[QMPaymentFinalizationViewController class]]) {
        QMPaymentFinalizationViewController *controller = segue.destinationViewController;
        [controller setShowTicketsButton:![self isAssinaturas:_url]];
    }
    [super prepareForSegue:segue sender:sender];
}


- (void)pollDocumentReadyState {
        if ([[_webview stringByEvaluatingJavaScriptFromString:@"(/loaded|complete/.test(document.readyState))"] caseInsensitiveCompare:@"true"] == NSOrderedSame) {
            NSLog(@"============================ LOADED ============================");
            [self hideScript];
            [SVProgressHUD dismiss];
            if ([self isLastStep]) {
                [self processOrderIfNeeded];
                [self performSegueWithIdentifier:@"paymentFinalizationSegue" sender:nil];
            } else {
                if ([self isSecondStep:_url]) {
                    [self showTutorialIfNeeded];
                }
                if ([self isThirdStep:_url]) {
                    /* Inject do código promocional caso necessário */
                    if (_promoCode) {
                        [self injectPromoCodeScript];
                    }
                }
                if ([self isLoginStep:_url]) {
                    [self injectCredentialsIfNeeded];
                }
                [UIView animateWithDuration:0.3 animations:^{
                     _webview.alpha = 1.0;
                }];
            }
        } else {
            [self performSelector:@selector(pollDocumentReadyState) withObject:nil afterDelay:0.2];
        }

}

- (void)injectCredentialsIfNeeded {
    QMUser *user = [QMUser sharedInstance];
    if (user.hasHash && user.email && user.password) {
         NSString *script = @"$('#login');";
        if ([_webview stringByEvaluatingJavaScriptFromString:script]) {
            script = [NSString stringWithFormat:@"$('#login').val('%@'); $('#senha').val('%@');", user.email, user.password];
            [_webview stringByEvaluatingJavaScriptFromString:script];
            script = @"$('#logar').click();";
            [_webview stringByEvaluatingJavaScriptFromString:script];
        }
    }
}

- (void)processOrderIfNeeded {
    if ([self isAssinaturas:_url]) {
        [self newOrderTasks];
    } else {
        QMOrder *order = [self processOrder];
        if (order.number && order.number.length > 0) {
            [self newOrderTasks];
        }
    }
}

- (QMOrder *)processOrder {
    NSString *jsonString = [self extractOrderJsonFromPageScript];
    NSDictionary *json = [self dictionaryWithJson:jsonString];
    QMOrder *order = [[QMOrder sharedInstance] initWithDictionary:json];
    [order setOriginalJson:jsonString];
    [QMOrder addOrderToHistory:order];
    return order;
}

- (void)newOrderTasks {
    [self notifyNewOrder];
    [self changeParseChannelFromProspectToClient];
    [self trackTransaction];
    [self trackTransactionOnGA];
    [self trackItemsOnGA];
}

- (void)changeParseChannelFromProspectToClient {
    [QMPushNotificationUtils unsubscribe:@"prospect"];
    [QMPushNotificationUtils subscribe:@"client"];
}

- (void)trackTransaction {
/* O Correto aqui seria criar uma fila de uploads pois não podemos perder nenhum post daqui.
     * mesmo se cair a conexão */
    [QMTrackPurchasesRequester postOrder:[QMOrder sharedInstance] onCompleteBlock:nil onFailBlock:nil];
}

- (void)trackTransactionOnGA {
//    if (!kIsDebugBuild) {
    QMOrder *order = [QMOrder sharedInstance];
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTransactionWithId:order.number
                                                     affiliation:@"compreingressos"
                                                         revenue:order.numericTotal
                                                             tax:@0
                                                        shipping:@0
                                                    currencyCode:nil] build]];
//    }
}

- (void)trackItemsOnGA {
//    if (!kIsDebugBuild) {
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    QMOrder *order = [QMOrder sharedInstance];
    NSArray *items = [self extractItemsFromGAScript];
    if (items || items.count > 0) {
        for (NSDictionary *itemDict in items) {
            [tracker send:[[GAIDictionaryBuilder createItemWithTransactionId:order.number
                                                                        name:itemDict[@"name"]
                                                                         sku:itemDict[@"sku"]
                                                                    category:itemDict[@"category"]
                                                                       price:itemDict[@"price"]
                                                                    quantity:itemDict[@"quantity"]
                                                                currencyCode:nil] build]];
        }
    }
//    }
}

- (void)notifyNewOrder {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOrderFinishedTag
                                                        object:self
                                                      userInfo:nil];
}

- (void)showFinalizationScreen {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];

    [CATransaction commit];
}


#pragma mark -
#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
        NSLog(@"DID_START_LOAD [%@]", [webView.request.URL absoluteString]);
}

- (NSDictionary *)dictionaryWithJson:(NSString *)json {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    return jsonDictionary;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"DID_FINISH_LOAD [%@]", [webView.request.URL absoluteString]);
//    NSString *script = @"var tok_result = ''; $('.destaque_menor_v2').each(function() { tok_result += $(this).find('h3').first().text()}); tok_result;";
//    NSString *result = [_webview stringByEvaluatingJavaScriptFromString:script];
//    NSLog(@"script output: %@", result);
//    NSString *script = @"var tok_result = ''; $('input[type=\"text\"]').each(function() {tok_result += $(this).val() + ' --- '}); tok_result;";
    [self hideScript];
    if (_firstTimeLoad) {
        [self pollDocumentReadyState];
        _firstTimeLoad = NO;
    } else {
        
    }

    [self hideNextButtonOnWebviewScript];
    if ([self isSecondStep:_url]) {
        [self changeViewPortForZoomingScript];
        _webview.scalesPageToFit = YES;
    }
    if ([self isSixthStep:_url]) {
        [self changePaymentProcessingMessage];
    }
//    NSString *script = @"$('input[id=\"login\"]').val();";
//    NSString *result = [_webview stringByEvaluatingJavaScriptFromString:script];
//    NSLog(@"script output: %@", result);
//    [self filterEmail:result];
}

- (void)changePaymentProcessingMessage {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"SHOULD_START_LOAD [%@]", [request.URL absoluteString]);
    NSString *body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    // NSLog(@"    BODY [%@]", body);
    
    NSString *url = [[request URL] absoluteString];
    if ([self isNextStep:url]) {
        [self openNextStep:url];
        return NO;
    }
    return YES;
}

- (void)openNextStep:(NSString *)url {
    if (kIsDebugBuild) {
        /* Troca a url do fluxo de compra para homol */
        if ([self isFirstStep:_url] && [_url rangeOfString:@"Turma-do-Chaves"].length == 0) {
            url = @"http://186.237.201.150:8081/compreingressos2/comprar/etapa1.php?apresentacao=61565";
            // url = @"http://186.237.201.132:81/compreingressos2/comprar/etapa1.php?apresentacao=61565";
            // url = @"http://186.237.201.132:81/compreingressos2/comprar/etapa1.php?apresentacao=71331&eventoDS=TER%C3%87AS%20APP"; /* assinatura */
        }
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QMWebViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"QMWebViewController"];
    [controller setUrl:url];
    [controller setPromoCode:_promoCode]; // forward do codigo promocional
    [self configureNextViewBackButtonWithTitle:@"Voltar"];
    [self.navigationController pushViewController:controller animated:YES];
    [_webview stopLoading];
}

- (BOOL)string:(NSString *)string matchesRegex:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange visibleRange = NSMakeRange(0, string.length);
    NSArray *matches = [regex matchesInString:string options:NSMatchingProgress range:visibleRange];
    return [matches count] > 0;
}

/* Tela do detalhe do Espetáculo */
- (BOOL)isFirstStep:(NSString *)url {
    return ([url rangeOfString:@"espetaculos"].length != 0);
}

/* Tela de escolha do assento */
- (BOOL)isSecondStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa1\\.php"];
}

/* Tela do tipo do ingresso */
- (BOOL)isThirdStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa2\\.php"];
}

/* Tela de login/cadastro */
- (BOOL)isFourthStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa3\\.php\\?redirect=etapa4\\.php"];
}

- (BOOL)isLoginStep:(NSString *)url {
    return [self isFourthStep:url];
}

/* Tela de confirmação */
- (BOOL)isFifthStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa4\\.php"] && [self string:url matchesRegex:@"^((?!etapa3\\.php).)*$"];
}

/* Tela de pagamento */
- (BOOL)isSixthStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa5\\.php"];
}

/* Tela final */
- (BOOL)isSeventhStep:(NSString *)url {
    return [self string:url matchesRegex:@"pagamento_ok"];
}

/* Assinaturas */
- (BOOL)isAssinaturas:(NSString *)url {
    return ([url rangeOfString:@"assinaturas"].length != 0);
}

- (BOOL)isLastStep {
    return [self isSeventhStep:_url];
}

- (BOOL)isNextStep:(NSString *)url {
    BOOL nextStep = NO;
    if (_isZerothStep && ![self isFirstStep:_url]) {
        nextStep = [self isFirstStep:url];
    }
    else if ([self isFirstStep:_url]) {
        nextStep = [self isSecondStep:url];
    }
    else if ([self isSecondStep:_url]) {
        nextStep = [self isThirdStep:url];
    }
    else if ([self isThirdStep:_url]) {
        nextStep = [self isFourthStep:url];
    }
    else if ([self isFourthStep:_url]) {
        nextStep = [self isFifthStep:url];
    }
    else if ([self isFifthStep:_url]) {
        nextStep = [self isSixthStep:url];
    }
    else if ([self isSixthStep:_url]) {
        nextStep = [self isSeventhStep:url] || [self isAssinaturas:url];
    }

    NSLog(@"Nextstep: %i", nextStep);
    return nextStep;
}

- (void)filterEmail:(NSString *)string {
    if ([string rangeOfString:@"@"].length > 0) {
        NSLog(@"-------------------------\n\n\n%@\n\n\n-------------------------", string);
    }
}

- (IBAction)clickedOnNativeButton:(id)sender {
    [self clickNextButtonOnWebviewScript];
}



#pragma mark -
#pragma mark - Scripts

- (NSArray *)extractItemsFromGAScript {
    NSString *script = @"var regex = /_gaq.push\\(\\['_addItem',[\\W]+'([\\d]+)',[\\W]+'([\\d_]+)',[\\W]+'([\\w \\-\\u00C0-\\u017F]+)',[\\W]+'([\\w \\-\\u00C0-\\u017F]+)',[\\W]+'([\\d\\.,]*)',[\\W]+'(\\d)'/g; "
        "var match; "
        "var ret = ''; "
        "while (match = regex.exec(document.documentElement.outerHTML)) { "
        "   var i; "
        "   for(i=1; i<= 6; i++) { "
        "       ret += match[i]; "
        "       if (i != 6) { "
        "           ret += '<.elem,>'; "
        "       } "
        "   } "
        "   ret = ret + '<.item,>'; "
        "} "
        "ret; ";
    NSString *data = [_webview stringByEvaluatingJavaScriptFromString:script];
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    @try {
        NSArray *itemsStringArray = [data componentsSeparatedByString:@"<.item,>"];
        for (NSString *itemString in itemsStringArray) {
            if (itemString.length > 0) {
                NSArray *elements = [itemString componentsSeparatedByString:@"<.elem,>"];
                NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
                itemDict[@"transaction"] = elements[0];
                itemDict[@"sku"]         = elements[1];
                itemDict[@"name"]        = elements[2];
                itemDict[@"category"]    = elements[3];
                itemDict[@"price"]       = [formatter numberFromString:elements[4]];
                itemDict[@"quantity"]    = [formatter numberFromString:elements[5]];
                [itemsArray addObject:itemDict];
            }
        }
    } @catch (NSException *e) {
        /* Cria uma QMException com o erro e adiciona o código fonte da página no more info */
        NSString *sourceCode = [_webview stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML;"];
        QMException *exception = [[QMException alloc] initWithNSException:e];
        [exception setMoreInfo:sourceCode];
        [exception post];
    }

    return itemsArray;
}

- (void)injectPromoCodeScript {
    NSString *format = @"var codigo = \"%@\"; "
            "var groups = /<a href=\"#([\\d]+)\" rel=\"[\\d]+\">PROMO APP<\\/a>/.exec(document.documentElement.outerHTML); "
            "var ref; "
            "if (groups.length == 2) ref = groups[1]; "
            "if (ref) { "
            "    $('a[href=\"#'+ref+'\"]').click(); "
            "    $('.container_beneficio').find('input[type=\"text\"]').val(codigo); "
            "    $('a[class^=\"validarBin\"]').click(); "
            "} ";
    NSString *script = [NSString stringWithFormat:format, _promoCode];
    [_webview stringByEvaluatingJavaScriptFromString:script];
    _promoCode = nil;
}


- (void)hideScript {
    NSString *script = @"$('p[class=\"creditos\"]').hide(); "
            "$('#menu_topo').hide(); "
            "$('.aba' && '.fechado').hide(); "
            "$('#footer').hide(); "
            "$('#selos').hide(); "
            "$('.botao' && '.voltar').hide(); "
            "$('.minha_conta').hide(); "
            "$('.meu_codigo_cartao').hide(); "
            "$('.imprima_agora').hide(); ";
    [_webview stringByEvaluatingJavaScriptFromString:script];
}

- (void)hideNextButtonOnWebviewScript {
    NSString *script = @"$('.container_botoes_etapas').hide(); ";
    [_webview stringByEvaluatingJavaScriptFromString:script];
}

- (void)changeViewPortForZoomingScript {
    NSString *script = @"var all_metas=document.getElementsByTagName('meta'); "
            @"if (all_metas){ "
            @"    var k; "
            @"    for (k=0; k<all_metas.length;k++) { "
            @"        var meta_tag=all_metas[k]; "
            @"        var viewport= meta_tag.getAttribute('name'); "
            @"        if (viewport&& viewport=='viewport'){ "
            @"            meta_tag.setAttribute('content','width=device-width; initial-scale=1.0; maximum-scale=5.0; user-scalable=1;'); "
            @"        } "
            @"    } "
            @"} ";
    [_webview stringByEvaluatingJavaScriptFromString:script];
}

- (void)clickNextButtonOnWebviewScript {
    NSString *script = @"var length = $('.container_botoes_etapas').find('a').length; "
            @"$('.container_botoes_etapas').find('a')[length - 1].click(); ";
    [_webview stringByEvaluatingJavaScriptFromString:script];
}

- (NSString *)extractOrderJsonFromPageScript {
    NSString *script = @"var date_aux = new Array; "
            @"$('.data').children().each(function(){date_aux.push($(this).html())}); "
            @"var order_date = date_aux.join(' '); "
            @"var spectacle_name = $('.resumo').find('.nome').html(); "
            @"var address = $('.resumo').find('.endereco').html(); "
            @"var theater = $('.resumo').find('.teatro').html(); "
            @"var time = $('.resumo').find('.horario').html(); "
            @"var order_number = $('.numero').find('a').html(); "
            @"var order_total = $('.pedido_total').find('.valor').html(); "
            @"var tickets = new Array; "
            @"$('tr').each(function() { "
            @"	var qrcode = $(this).attr('data:uid'); "
            @"	if (typeof qrcode !== typeof undefined && qrcode !== false) { "
            @"		var local   = $(this).find('.local').find('td').html().replace('<br>', '').split('\\n').map(trim).join(' ').trim(); "
            @"		var type    = $(this).find('.tipo').html(); "
            @"		var aux     = $(this).find('td'); "
            @"		var price   = aux.eq(3).children().eq(0).html(); "
            @"		var service = aux.eq(4).html().replace('R$', ''); "
            @"		var total   = aux.eq(5).children().eq(0).html(); "
            @"		tickets.push({ "
            @"			qrcode:        qrcode, "
            @"			local:         local, "
            @"			type:          type, "
            @"			price:         price, "
            @"			service_price: service, "
            @"			total:         total "
            @"		}); "
            @"	} "
            @"}); "
            @"var payload = { "
            @"		number: order_number, "
            @"		date:   order_date, "
            @"		total:  order_total, "
            @"		espetaculo: { "
            @"			titulo: spectacle_name, "
            @"			endereco: address, "
            @"			nome_teatro: theater, "
            @"			horario: time "
            @"		}, "
            @"		ingressos: tickets "
            @"}; "
            @"JSON.stringify(payload); ";

    NSString *json = [_webview stringByEvaluatingJavaScriptFromString:script];
    return json;
}

@end
