//
//  QMWebViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/17/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMWebViewController.h"
//#import "SVProgressHUD.h"

@interface QMWebViewController () {
    UIWebView *_webview;
    NSString *_url;
//    NSString *_title;
    BOOL _firstTimeLoad;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self openUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openUrl {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?app=tokecompre", _url]];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [_webview loadRequest:requestURL];
//    [SVProgressHUD show];
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
    NSLog(@"polling");
    if ([[_webview stringByEvaluatingJavaScriptFromString:@"document.UIWebViewDocumentIsReady;"] caseInsensitiveCompare:@"true"] == NSOrderedSame) {
        NSString *hideScript = @"$('p[class=\"creditos\"]').hide(); "
        "$('#menu_topo').hide(); "
        "$('.aba' && '.fechado').hide(); ";
        [_webview stringByEvaluatingJavaScriptFromString:hideScript];
        NSLog(@"==================== LOADED ============================");
    } else {
        [self performSelector:@selector(pollDocumentReadyState) withObject:nil afterDelay:0.2];
    }
}

#pragma mark -
#pragma mark - UIWebViewDelegate


- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSString *script = @"var tok_result = ''; $('.destaque_menor_v2').each(function() { tok_result += $(this).find('h3').first().text()}); tok_result;";
//    NSString *result = [_webview stringByEvaluatingJavaScriptFromString:script];
//    NSLog(@"script output: %@", result);
//    NSString *script = @"var tok_result = ''; $('input[type=\"text\"]').each(function() {tok_result += $(this).val() + ' --- '}); tok_result;";
    if (_firstTimeLoad) {
        NSString *detectDOMReadyScript = @"if (/loaded|complete/.test(document.readyState)) "
        "{ "
        "    document.UIWebViewDocumentIsReady = true; "
        "} "
        "else "
        "{ "
        "    document.addEventListener('DOMContentLoaded', function(){document.UIWebViewDocumentIsReady = true;}, false); "
        "} ";
        [_webview stringByEvaluatingJavaScriptFromString:detectDOMReadyScript];
        _firstTimeLoad = NO;
        [self pollDocumentReadyState];
    } else {
    }
    
//    NSString *script = @"$('input[id=\"login\"]').val();";
//    NSString *result = [_webview stringByEvaluatingJavaScriptFromString:script];
//    NSLog(@"script output: %@", result);
//    [self filterEmail:result];
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
//    NSString *script = @"$('input[id=\"login\"]').val();";
//    NSString *result = [_webview stringByEvaluatingJavaScriptFromString:script];
//    NSLog(@"script output: %@", result);
//    [self filterEmail:result];
    return YES;
}

- (void)filterEmail:(NSString *)string {
    if ([string rangeOfString:@"@"].length > 0) {
        NSLog(@"-------------------------\n\n\n%@\n\n\n-------------------------", string);
    }
}

@end
