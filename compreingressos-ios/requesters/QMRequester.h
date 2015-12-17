//
// Created by Robinson Nakamura on 12/03/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SERVER_PROD
//#define SERVER_HOMOL
//#define SERVER_TEST
//#define SERVER_LOCAL

static BOOL kDebug = NO;
static BOOL kOfflineMode = NO;
#pragma unused (kDebug, kOfflineMode)

static NSString *kProdHost  = @"https://tokecompre-ci.herokuapp.com";
static NSString *kHomolHost = @"http://qprodelivery-homol.herokuapp.com";
static NSString *kTestHost  = @"http://tok-otimizacao.herokuapp.com";
static NSString *kLocalHost = @"http://0.0.0.0:5001";
#pragma unused (kLocalHost, kProdHost, kHomolHost)

//static NSString *kNtkHost = @"http://cert.gate2all.com.br";
//static NSString *kNtkHost = @"http://ntk-stub.herokuapp.com";
//static NSString *kNtkHost = @"http://0.0.0.0:5000";
static NSString *kNtkUrlRetorno = @"ws/orders/ntk_callback";

static NSString *const kCompreIngressoHost = @"https://tokecompre-ci.herokuapp.com";
static NSString *const kMPassbookHost = @"https://mpassbook.herokuapp.com";

static NSString *const kWifiCon = @"wifi";
static NSString *const kWwanCon = @"wwan";
static NSURLRequestCachePolicy kOfflineCachePolicy = NSURLRequestReturnCacheDataElseLoad;
static NSURLRequestCachePolicy kDefaultCachePolicy = NSURLRequestUseProtocolCachePolicy;
#pragma unused (kOfflineCachePolicy, kDefaultCachePolicy)

static NSString *kUrlIdTag = @"<id>";

static NSString *kQuestionMark = @"?";
static NSString *kAndMark = @"&";
static NSString *kEqualMark = @"=";

@interface QMRequester : NSObject

+ (NSString *)addVersionToUrl:(NSString *)url;
+ (NSMutableString *)addQueryStringParamenter:(NSString *)parameter withValue:(NSString *)value toUrl:(NSString *)url;
+ (BOOL)offlineMode;
+ (NSURLRequestCachePolicy)cachePolicy;
+ (dispatch_queue_t)getDispatchQueue;
+ (CGFloat)requestTimeout;
+ (void)setRequestTimeout:(CGFloat)timeout;
+ (NSError *)errorFromException:(NSException *)exception;
+ (NSError *)errorFromWsMessage:(NSString *)message;
+ (NSError *)errorFromWsMessage:(NSString *)string forField:(NSString *)field;
+ (NSString *)getHost;
+ (NSString *)getUrlForPath:(NSString *)path;
+ (NSString *)urlEncodeString:(NSString *)string;
+ (BOOL)isTimeoutError:(NSError *)error;
+ (void)printDebugMessage:(NSString *)message withTag:(NSString *)tag;
+ (void)printDebugMessageWithError:(NSError *)error withTag:(NSString *)tag;
+ (id)objectOrNilForKey:(NSString *)key forDictionary:(NSDictionary *)dictionary;
+ (BOOL)booleanForKey:(NSString *)key forDictionary:(NSDictionary *)dictionary;
+ (NSString *)connectionType;
+ (BOOL)isWifi;

@end