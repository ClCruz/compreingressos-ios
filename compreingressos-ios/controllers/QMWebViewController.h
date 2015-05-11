//
//  QMWebViewController.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/17/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMGenre;
@class QMEspetaculo;

@interface QMWebViewController : UIViewController <UIWebViewDelegate> {
    
}

@property (nonatomic, strong) NSString *url;
//@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) QMGenre *genre;
@property (nonatomic, strong) QMEspetaculo *espetaculo;
@property (strong, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic) BOOL isZerothStep;

- (IBAction)clickedOnNativeButton:(id)sender;

@end
