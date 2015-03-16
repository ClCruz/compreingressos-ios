//
//  QMWebViewController.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/17/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMWebViewController : UIViewController <UIWebViewDelegate> {
    
}

@property (nonatomic, strong) NSString *url;
//@property (nonatomic, strong) NSString *title;
@property (strong, nonatomic) IBOutlet UIWebView *webview;

@end
