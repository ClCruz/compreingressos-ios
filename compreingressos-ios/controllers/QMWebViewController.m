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
#import "compreingressos-ios-Prefix.pch"

static NSNumber *defaultWebViewBottomSpacing = nil;

@interface QMWebViewController () {
    UIWebView                   *_webview;
    NSString                    *_url;
    QMGenre                     *_genre;
    QMEspetaculo                *_espetaculo;
    BOOL                         _firstTimeLoad;
    BOOL                         _loaded;
    BOOL                         _isZerothStep;
    IBOutlet UIButton           *_nativeButton;
    IBOutlet UIView             *_nativeButtonContainer;
    IBOutlet NSLayoutConstraint *_webviewBottomSpacing;
}

@end

@implementation QMWebViewController

@synthesize webview      = _webview;
@synthesize url          = _url;
@synthesize genre        = _genre;
@synthesize espetaculo   = _espetaculo;
@synthesize isZerothStep = _isZerothStep;

- (void)viewDidLoad {
    [super viewDidLoad];
    _webview.delegate = self;
    _firstTimeLoad = YES;
    _loaded = NO;
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
        defaultWebViewBottomSpacing = [NSNumber numberWithFloat:_webviewBottomSpacing.constant];
    }
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
}

- (void)removeLoginControllerFromQueue {
    int count = (int)[self.navigationController.viewControllers count];
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
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
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
    /* Se não recebemos uma url, estamos no fluxo inicial, iremos montar a url a partir do espetáculo */
    if (_url && ![_url containsString:@"app=tokecompre"]) {
        _url = [QMRequester addQueryStringParamenter:@"app" withValue:@"tokecompre" toUrl:_url];
    }
    NSURL *url = [NSURL URLWithString:_url];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    _webview.alpha = 0.0;
    [_webview loadRequest:requestURL];
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
    NSString *title = nil;
    if (_isZerothStep) {
        title = @"Destaque";
    }
    if ([self isFirstStep:_url]) {
        if (_espetaculo) {
            title = _espetaculo.titulo;
        } else {
            title = @"Espetáculo";
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

    return title;
}

- (void)configureNextViewBackButtonWithTitle:(NSString *)title {
    UIBarButtonItem *nextViewBackButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:nil
                                                                          action:nil];
    [self.navigationItem setBackBarButtonItem:nextViewBackButton];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController]
    // Pass the selected object to the new view controller.
}
*/

- (void)pollDocumentReadyState {
//    NSLog(@"polling %@", [_webview stringByEvaluatingJavaScriptFromString:@"(/loaded|complete/.test(document.readyState))"]);

        if ([[_webview stringByEvaluatingJavaScriptFromString:@"(/loaded|complete/.test(document.readyState))"] caseInsensitiveCompare:@"true"] == NSOrderedSame) {
//            NSLog(@"==================== LOADED ============================");
            [self hideScript];
            [SVProgressHUD dismiss];
            _loaded = YES;
            if ([self isLastStep]) {
                [self processOrder];
                [self performSegueWithIdentifier:@"paymentFinalizationSegue" sender:nil];
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    _webview.alpha = 1.0;
                }];
            }
        } else {
            [self performSelector:@selector(pollDocumentReadyState) withObject:nil afterDelay:0.2];
        }

}

- (void)processOrder {
    NSString *jsonString = [self extractOrderJsonFromPage];
    NSDictionary *json = [self dictionaryWithJson:jsonString];
    QMOrder *order = [[QMOrder sharedInstance] initWithDictionary:json];
    [order setOriginalJson:jsonString];
    [QMOrder addOrderToHistory:order];
    if (order.number && order.number.length > 0) {
        [self notifyNewOrder];
    }
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

- (void)hideScript {
    NSString *hideScript = @"$('p[class=\"creditos\"]').hide(); "
    "$('#menu_topo').hide(); "
    "$('.aba' && '.fechado').hide(); "
    "$('#footer').hide(); "
    "$('#selos').hide(); "
    "$('.botao' && '.voltar').hide(); "
    "$('.minha_conta').hide(); "
    "$('.meu_codigo_cartao').hide(); "
    "$('.imprima_agora').hide(); ";
    [_webview stringByEvaluatingJavaScriptFromString:hideScript];
}

- (void)hideNextButtonOnWebview {
    NSString *script = @"$('.container_botoes_etapas').hide(); ";
    [_webview stringByEvaluatingJavaScriptFromString:script];
}

- (void)changeViewPortForZooming {
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

- (void)clickNextButtonOnWebview {
    NSString *script = @"var length = $('.container_botoes_etapas').find('a').length; "
    @"$('.container_botoes_etapas').find('a')[length - 1].click(); ";
    [_webview stringByEvaluatingJavaScriptFromString:script];
}

- (NSString *)extractOrderJsonFromPage {
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
    
    [self hideNextButtonOnWebview];
    if ([self isSecondStep:_url]) {
        [self changeViewPortForZooming];
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
    NSLog(@"    BODY [%@]", body);
    
    NSString *url = [[request URL] absoluteString];
    if ([self isNextStep:url]) {
        /* Troca a url do fluxo de compra para homol */
        if ([self isFirstStep:_url]) {
            url = @"http://186.237.201.132:81/compreingressos2/comprar/etapa1.php?apresentacao=61566&eventoDS=COSI%20FAN%20TUT%20TE";
        }
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        QMWebViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"QMWebViewController"];
        [controller setUrl:url];
        [self configureNextViewBackButtonWithTitle:@"Voltar"];
        [self.navigationController pushViewController:controller animated:YES];
        [_webview stopLoading];
        return NO;
    }
    
    return YES;
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
    return [url containsString:@"espetaculos"];
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
        nextStep = [self isSeventhStep:url];
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
    [self clickNextButtonOnWebview];
}

@end
