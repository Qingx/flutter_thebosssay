#import "TalkingDataAppAnalyticsPlugin.h"
#import "TalkingData.h"

@implementation TalkingDataAppAnalyticsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"TalkingData_AppAnalytics"
            binaryMessenger:[registrar messenger]];
    TalkingDataAppAnalyticsPlugin* instance = [[TalkingDataAppAnalyticsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}


+(void)pluginSessionStart:(NSString*)session withChannelId:(NSString*)channelID
{
    [TalkingData sessionStarted:session withChannelId:channelID];
}


-(id)checkArgument:(NSDictionary*)argument forKey:(NSString*)key ofType:(Class)clazz
{
    if (key == nil || argument == nil || clazz == nil  ) {
        return nil;
    }
    id arg = [argument objectForKey:key];
    if (arg == nil) {
        return nil;
    }
    if (![arg isKindOfClass:clazz]) {
        return nil;
    }
    return arg;
}


-(TDProfileType)profileTypeConvert:(NSString*)accTypeStr
{
    if ([accTypeStr isEqualToString:@"ANONYMOUS"]) {
        return TDProfileTypeAnonymous;
    }else if ([accTypeStr isEqualToString:@"REGISTERED"]){
        return TDProfileTypeRegistered;
    }else if ([accTypeStr isEqualToString:@"SINA_WEIBO"]){
        return TDProfileTypeSinaWeibo;
    }else if ([accTypeStr isEqualToString:@"QQ"]){
        return TDProfileTypeQQ;
    }else if ([accTypeStr isEqualToString:@"QQ_WEIBO"]){
        return TDProfileTypeTencentWeibo;
    }else if ([accTypeStr isEqualToString:@"ND91"]){
        return TDProfileTypeND91;
    }else if ([accTypeStr isEqualToString:@"WEIXIN"]){
        return TDProfileTypeWeiXin;
    }else if ([accTypeStr isEqualToString:@"TYPE1"]){
        return TDProfileTypeType1;
    }else if ([accTypeStr isEqualToString:@"TYPE2"]){
        return TDProfileTypeType2;
    }else if ([accTypeStr isEqualToString:@"TYPE3"]){
        return TDProfileTypeType3;
    }else if ([accTypeStr isEqualToString:@"TYPE4"]){
        return TDProfileTypeType4;
    }else if ([accTypeStr isEqualToString:@"TYPE5"]){
        return TDProfileTypeType5;
    }else if ([accTypeStr isEqualToString:@"TYPE6"]){
        return TDProfileTypeType6;
    }else if ([accTypeStr isEqualToString:@"TYPE7"]){
        return TDProfileTypeType7;
    }else if ([accTypeStr isEqualToString:@"TYPE8"]){
        return TDProfileTypeType8;
    }else if ([accTypeStr isEqualToString:@"TYPE9"]){
        return TDProfileTypeType9;
    }else if ([accTypeStr isEqualToString:@"TYPE10"]){
        return TDProfileTypeType10;
    }
    return TDProfileTypeAnonymous;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"onPageStart" isEqualToString:call.method]){
        NSString * pageName = [self checkArgument:call.arguments forKey:@"pageName" ofType:[NSString class]];
        if (pageName) {
            [TalkingData trackPageBegin:pageName];
        }
    } else if ([@"onPageEnd" isEqualToString:call.method]){
        NSString * pageName = [self checkArgument:call.arguments forKey:@"pageName" ofType:[NSString class]];
        if (pageName) {
            [TalkingData trackPageEnd:pageName];
        }
    } else  if ([@"onRegister" isEqualToString:call.method]){
        NSString * profileID = [self checkArgument:call.arguments forKey:@"profileID" ofType:[NSString class]];
        NSString * profileType = [self checkArgument:call.arguments forKey:@"profileType" ofType:[NSString class]];
        NSString * name = [self checkArgument:call.arguments forKey:@"name" ofType:[NSString class]];
        if (profileID && profileType && name) {
            TDProfileType acctype = [self profileTypeConvert:profileType];
            [TalkingData onRegister:profileID type:acctype name:name];
        }
    } else if ([@"onLogin" isEqualToString:call.method]){
        NSString * profileID = [self checkArgument:call.arguments forKey:@"profileID" ofType:[NSString class]];
        NSString * profileType = [self checkArgument:call.arguments forKey:@"profileType" ofType:[NSString class]];
        NSString * name = [self checkArgument:call.arguments forKey:@"name" ofType:[NSString class]];
        if (profileID && profileType && name) {
            TDProfileType acctype = [self profileTypeConvert:profileType];
            [TalkingData onLogin:profileID type:acctype name:name];
        }
    } else if ([@"onEvent" isEqualToString:call.method]){
        NSString * eventID = [self checkArgument:call.arguments forKey:@"eventID" ofType:[NSString class]];
        NSString * eventLabel = [self checkArgument:call.arguments forKey:@"eventLabel" ofType:[NSString class]];
        NSDictionary * params = [self checkArgument:call.arguments forKey:@"params" ofType:[NSDictionary class]];
        if (eventID) {
            [TalkingData trackEvent:eventID label:eventLabel parameters:params];
        }
    }else if([@"onEventWithValue" isEqualToString:call.method]){
        NSString * eventID = [self checkArgument:call.arguments forKey:@"eventID" ofType:[NSString class]];
        NSString * eventLabel = [self checkArgument:call.arguments forKey:@"eventLabel" ofType:[NSString class]];
        NSDictionary * params = [self checkArgument:call.arguments forKey:@"params" ofType:[NSDictionary class]];
        NSNumber * value = [self checkArgument:call.arguments forKey:@"value" ofType:[NSNumber class]];

        if (eventID) {
//#error 记得更新最新的.a和.h，然后打开下边的注释。
            [TalkingData trackEvent:eventID label:eventLabel parameters:params value:value.doubleValue];
        }
        
    }  else if ([@"onViewItem" isEqualToString:call.method]){
        NSString* category = [self checkArgument:call.arguments forKey:@"category" ofType:[NSString class]];
        NSString* itemID = [self checkArgument:call.arguments forKey:@"itemID" ofType:[NSString class]];
        NSString* name = [self checkArgument:call.arguments forKey:@"name" ofType:[NSString class]];
        NSNumber* unitPrice = [self checkArgument:call.arguments forKey:@"unitPrice" ofType:[NSNumber class]];
        [TalkingData onViewItem:itemID category:category name:name unitPrice:unitPrice.intValue];
        
    } else if ([@"onAddItemToShoppingCart" isEqualToString:call.method]){
        NSNumber * amount = [self checkArgument:call.arguments forKey:@"amount" ofType:[NSNumber class]];
        NSString * category = [self checkArgument:call.arguments forKey:@"category" ofType:[NSString class]];
        NSString * itemID = [self checkArgument:call.arguments forKey:@"itemID" ofType:[NSString class]];
        NSString * name = [self checkArgument:call.arguments forKey:@"name" ofType:[NSString class]];
        NSNumber * uniprice = [self checkArgument:call.arguments forKey:@"unitPrice" ofType:[NSNumber class]];
        [TalkingData onAddItemToShoppingCart:itemID category:category name:name unitPrice:uniprice.intValue amount:amount.intValue];
    } else if ([@"onViewShoppingCart" isEqualToString:call.method]){
        NSArray * shoppingCartDetails = [self checkArgument:call.arguments forKey:@"shoppingCartDetails" ofType:[NSArray class]];
        TalkingDataShoppingCart * sc = [TalkingDataShoppingCart createShoppingCart];
        for (NSDictionary* each in shoppingCartDetails) {
            NSNumber * amount = [self checkArgument:each forKey:@"amount" ofType:[NSNumber class]];
            NSString * category = [self checkArgument:each forKey:@"category" ofType:[NSString class]];
            NSString * itemID = [self checkArgument:each forKey:@"itemID" ofType:[NSString class]];
            NSString * name = [self checkArgument:each forKey:@"name" ofType:[NSString class]];
            NSNumber * uniprice = [self checkArgument:each forKey:@"unitPrice" ofType:[NSNumber class]];
            [sc addItem:itemID category:category name:name unitPrice:uniprice.intValue amount:amount.intValue];
        }
        [TalkingData onViewShoppingCart:sc];
    } else if ([@"onPlaceOrder" isEqualToString:call.method]){
        NSString * orderId = [self checkArgument:call.arguments forKey:@"orderId" ofType:[NSString class]];
        NSString * amount = [self checkArgument:call.arguments forKey:@"amount" ofType:[NSNumber class]];
        NSArray * currencyType = [self checkArgument:call.arguments forKey:@"currencyType" ofType:[NSString class]];
        [TalkingData onPlaceOrder:orderId amount:amount currencyType:currencyType];
        
    } else if ([@"onOrderPaySucc" isEqualToString:call.method]){
        NSString * orderId = [self checkArgument:call.arguments forKey:@"orderId" ofType:[NSString class]];
        NSString * amount = [self checkArgument:call.arguments forKey:@"amount" ofType:[NSNumber class]];
        NSArray * currencyType = [self checkArgument:call.arguments forKey:@"currencyType" ofType:[NSString class]];
        NSArray * paymentType = [self checkArgument:call.arguments forKey:@"paymentType" ofType:[NSString class]];
        [TalkingData onOrderPaySucc:orderId amount:amount currencyType:currencyType paymentType:paymentType];

    } else if ([@"onCancelOrder" isEqualToString:call.method]){
        NSString * orderId = [self checkArgument:call.arguments forKey:@"orderId" ofType:[NSString class]];
        NSString * amount = [self checkArgument:call.arguments forKey:@"amount" ofType:[NSNumber class]];
        NSArray * currencyType = [self checkArgument:call.arguments forKey:@"currencyType" ofType:[NSString class]];
        [TalkingData onCancelOrder:orderId amount:amount currencyType:currencyType];

    } else if ([@"setGlobalKV" isEqualToString:call.method]) {
        NSString * key = [self checkArgument:call.arguments forKey:@"key" ofType:[NSString class]];
        id value = call.arguments[@"value"];
        if (value) {
            [TalkingData setGlobalKV:key value:value];
        }
    }else if ([@"removeGlobalKV" isEqualToString:call.method]){
        NSString * key = [self checkArgument:call.arguments forKey:@"key" ofType:[NSString class]];
        [TalkingData removeGlobalKV:key];
    }else if ([@"getDeviceID" isEqualToString:call.method]){
        NSString * deviceid = [TalkingData getDeviceID];
        result(deviceid);
    }else {
        result(FlutterMethodNotImplemented);
    }
}


@end
