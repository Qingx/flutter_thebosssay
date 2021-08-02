//
//   AppScore.m
   

#import "AppScore.h"
#import <StoreKit/StoreKit.h>

@interface AppScore()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation AppScore

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"app.storescore/storescore"
                  binaryMessenger:[registrar messenger]];
    AppScore *instance = [[AppScore alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}




- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
    if([@"cancel" isEqualToString:call.method]) {
        
    } else if ([@"storeScore" isEqualToString:call.method]) {

        [self setStartAppStore];
        result([NSNumber numberWithBool:true]);

    } else {
        result(FlutterMethodNotImplemented);
    }
}



- (void)setStartAppStore
{
    if (@available(iOS 10.0, *)) {
        [SKStoreReviewController requestReview];
    }
    else {
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"12323123123"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    }
}



@end
