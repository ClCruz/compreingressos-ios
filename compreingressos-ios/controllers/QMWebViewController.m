//
//  QMWebViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/17/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMWebViewController.h"
#import "SVProgressHUD.h"

@interface QMWebViewController () {
    UIWebView *_webview;
    NSString *_url;
//    NSString *_title;
    BOOL _firstTimeLoad;
    BOOL _loaded;
}

@end

@implementation QMWebViewController

@synthesize webview = _webview;
@synthesize url = _url;
//@synthesize title = _title;

- (void)viewDidLoad {
    [super viewDidLoad];
    _webview.delegate = self;
    _firstTimeLoad = YES;
    _loaded = NO;
    if ([self isLastStep]) {
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar" style:UIBarButtonItemStyleDone target:self action:@selector(clickedOnCloseButton)];
        self.navigationItem.rightBarButtonItem = closeButton;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_firstTimeLoad) {
        [self openUrl];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openUrl {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?app=tokecompre", _url]];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [_webview loadRequest:requestURL];
    [SVProgressHUD show];
}

- (void)clickedOnCloseButton {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)pollDocumentReadyState {
//    NSLog(@"polling %@", [_webview stringByEvaluatingJavaScriptFromString:@"(/loaded|complete/.test(document.readyState))"]);

        if ([[_webview stringByEvaluatingJavaScriptFromString:@"(/loaded|complete/.test(document.readyState))"] caseInsensitiveCompare:@"true"] == NSOrderedSame) {
//            NSLog(@"==================== LOADED ============================");
            [self hideScript];
            [_webview setHidden:NO];
            [SVProgressHUD dismiss];
            _loaded = YES;
        } else {
            [self performSelector:@selector(pollDocumentReadyState) withObject:nil afterDelay:0.2];
        }

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
    "$('#overlay').hide(); "
    "$('#footer').hide(); "
    "$('#selos').hide(); "
    "$('.botao' && '.voltar').hide(); ";
    [_webview stringByEvaluatingJavaScriptFromString:hideScript];
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
//    NSString *script = @"$('input[id=\"login\"]').val();";
//    NSString *result = [_webview stringByEvaluatingJavaScriptFromString:script];
//    NSLog(@"script output: %@", result);
//    [self filterEmail:result];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"SHOULD_START_LOAD [%@]", [request.URL absoluteString]);
    NSString *body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    NSLog(@"    BODY [%@]", body);
    
    NSString *url = [[request URL] absoluteString];
    if ([self isNextStep:url]) {
        /* Troca a url do fluxo de compra para homol */
        if ([self isSecondStep:_url]) {
            url = @"http://186.237.201.132:81/compreingressos2/comprar/etapa1.php?apresentacao=61566&eventoDS=COSI%20FAN%20TUT%20TE";
        }
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        QMWebViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"QMWebViewController"];
        [controller setUrl:url];
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

- (BOOL)isFirstStep:(NSString *)url {
    return [url isEqualToString:@"http://www.compreingressos.com/espetaculos"];
}

- (BOOL)isSecondStep:(NSString *)url {
    return [self string:url matchesRegex:@"[\\d]+-[\\w-]+"];
}

- (BOOL)isThirdStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa1\\.php"];
}

- (BOOL)isFourthStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa2\\.php"];
}

- (BOOL)isFifthStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa3\\.php\\?redirect=etapa4\\.php"];
}

- (BOOL)isSixthStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa4\\.php"] && [self string:url matchesRegex:@"^((?!etapa3\\.php).)*$"];
}

- (BOOL)isSeventhStep:(NSString *)url {
    return [self string:url matchesRegex:@"etapa5\\.php"];
}

- (BOOL)isEighthStep:(NSString *)url {
    return [self string:url matchesRegex:@"pagamento_ok"];
}

- (BOOL)isLastStep {
    return [self isEighthStep:_url];
}

- (BOOL)isNextStep:(NSString *)url {
    BOOL nextStep = NO;
    if ([self isFirstStep:_url]) {
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
    else if ([self isSeventhStep:_url]) {
        nextStep = [self isEighthStep:url];
    }
    
    
    NSLog(@"Nextstep: %i", nextStep);
    return nextStep;
}

- (void)filterEmail:(NSString *)string {
    if ([string rangeOfString:@"@"].length > 0) {
        NSLog(@"-------------------------\n\n\n%@\n\n\n-------------------------", string);
    }
}

@end
