# flutter-talkingdata-appanalytics

App Analytics flutter 平台 SDK 由`封装层`和`Native SDK`两部分构成，目前Github上提供了封装层代码，需要从 [TalkingData官网](https://www.talkingdata.com/spa/sdk/#/config) 下载最新版的 Android 和 iOS 平台 Native SDK，组合使用。

## 目录

* [集成说明](#集成说明)
* [集成示例](#集成示例)
* [注意事项](#注意事项)
* [接口说明](#接口说明)



## 集成说明

### IOS

**项目文件夹中的静态库仅做演示使用，若用于生产环境，请到TalkingData官网申请最新版本的静态库，并且对本插件项目中的静态库和头文件进行替换**

需要替换的文件如下图所示:

![iOS_replace](/Users/existmg/workspace/flutter/app/sdk-talkingdata-sdk-flutter-plugin/img/iOS_replace.png)

### Android

**项目文件夹中的jar包仅做演示使用，若用于生产环境，请到TalkingData官网申请最新版本的jar包并进行替换，并且修改build.gradle中的jar包版本**

需要替换的文件如下图：

![android_replace_jar](/Users/existmg/workspace/flutter/app/sdk-talkingdata-sdk-flutter-plugin/img/android_replace_jar.png)

需要修改build.gradle中对应jar包的版本如下图：

![android_replace_build](/Users/existmg/workspace/flutter/app/sdk-talkingdata-sdk-flutter-plugin/img/android_replace_build.png)

Flutter共有三种方式集成插件，它们分别是：

1. Pub方式，插件开发者将插件发布到Flutter的统一插件开发平台，开发者远程集成
2. Git方式，开发者将插件放置于github或者gitlab上，远程集成
3. 本地集成，开发者将插件放在本地，方便开发者修改。

本插件项目采用第`3`种方式进行。


## 集成示例

这里是示例，请开发者按照示例步骤操作。

为了演示过程清晰，集成示例均在`test`文件夹下进行。

```shell
mkdir test
cd test
git clone 本项目 
flutter create myapp
```

此时`test`文件夹下包含：

- `myapp` 新创建的flutter App
- `appanalytics` TalkingData的插件工程

![test_1](/Users/existmg/workspace/flutter/app/sdk-talkingdata-sdk-flutter-plugin/img/test_1.png)

编辑`myapp/pubspec.yaml`,在`dependencies` 和 `dev_dependencies` 添加对`appanalytics`插件的的**本地依赖**：

```diff
dependencies:
  flutter:
    sdk: flutter
+ talkingdata_appanalytics_plugin:
+   path: ../appanalytics
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
+ talkingdata_appanalytics_plugin:
+   path: ../appanalytics 
    
```

1. 注意缩进
2. 注意路径，这里采用的相对路径，如果插件在其他位置，请注意修改插件路径为正确的相对路径或绝对路径。
3. 记得保存修改

在app项目里安装本地插件

```shell
cd myapp
flutter packages get
```

### IOS

安装相关依赖

```shell
cd myapp/ios
pod install
```

双击打开`myapp/ios/Runner.xcworkspace` 在 `AppDelegate.m` 中添加以下代码:

```diff
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
+#import <talkingdata_appanalytics_plugin/TalkingDataAppAnalyticsPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
+    [TalkingDataAppAnalyticsPlugin pluginSessionStart:@"YourAppID" withChannelId:@"YourChannel"];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
```

打开`myapp/lib/main.dart` ，添加对插件包的引用:

```diff
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';
```

此时双击`Runner.xcworkspace`运行myapp.

项目运行点击按钮，可以在Xcode或者终端控制台，看到接口调动log输出。完成集成。

### Android

在`myapp/android`模块下您的`Application`类的`onCreate`方法中调用初始化代码。如果没有的话，您也可以在您的`MainActivity`的`onCreate`回调中调用相关的初始化代码

``` diff
+  import com.talkingdata.plugin.appanalytics.TalkingDataAppAnalyticsPlugin;

     class MyApplication extends FlutterApplication{
       @Override
       public void onCreate() {
         super.onCreate();
+        TalkingDataAppAnalyticsPlugin.init(getApplicationContext(), "Your App ID", "Channel ID");
       }
   }
```

如果您的应用中SDK需要延后初始化，可以参考以下方式在对应的dart文件中对SDK进行初始化。使用此方式进行初始化时，请尽量保证第一时间进行初始化接口的调用

```dart
String appID = "Your App ID";
String channelID = "Channel ID";            
TalkingDataAppAnalytics.init(appID,channelID);
```

在`myapp/android`模块下的`AndroidManifest.xml `中添加以下权限：

``` diff
<!--?xml version="1.0" encoding="utf-8"?-->
<manifest ......>
+  <uses-permission android:name="android.permission.INTERNET" /><!-- 允许程序联网和发送统计数据的权限。-->
+  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" /><!-- 允许应用检测网络连接状态，在网络异常状态下避免数据发送，节省流量和电量。-->
+  <uses-permission android:name="android.permission.READ_PHONE_STATE"  /><!-- 允许应用以只读的方式访问手机设备的信息，通过获取的信息来唯一标识用户。-->
+  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"  /><!-- 获取设备的MAC地址，同样用来标识唯一用户。-->
+  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"  /><!-- 用于保存设备信息，以及记录日志。-->
+  <uses-permission android:name="android.permission.GET_TASKS"  /><!-- (建议配置) 获取当前应用是否在显示应用，可以更精准的统计用户活跃-->
+  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"  /><!-- (可选权限) 可通过GPS获取设备的位置信息，用来修正用户的地域分布数据，使报表数据更准确。-->
+  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"  /><!-- (可选权限) 用来获取该应用被使用的粗略位置信息。-->

  <application ......>
  <activity ......>
  ......
  </activity>
  ......
  </application>
</manifest>
```

打开`myapp/lib/main.dart` ，添加对插件包的引用:

```diff
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';
```

在myapp的路径下执行`flutter run`，运行您的项目



### 注意事项

1. 分别选择 Android 和 iOS 平台进行功能定制时，请确保两个平台功能项一致。

2. 如果申请 Native SDK 时只选择了部分功能，则需要在本项目中删除未选择功能对应的封装层代码。

   a) 未选择`自定义事件`功能则删除以下4部分

   删除 `lib/talkingdata_appanalytics_plugin.dart` 文件中如下代码：

   ```dart
   static Future<void> onEvent({@required String eventID, String eventLabel, Map params}) async{
     ...
   }
   
   static Future<void> setGlobalKV(String key, Object value) async{
     ...
   }
   
   static Future<void> removeGlobalKV(String key) async{
     ...
   }
   ```

   删除 `android/src/main/java/com/talkingdata/plugin/appanalytics/TalkingDataAppAnalyticsPlugin.java` 文件中如下代码：

   ```java
   case "onEvent":
     String eventID = call.argument("eventID");
     String eventLabel = call.argument("eventLabel");
     Map params = null;
     if (call.argument("params") instanceof Map){
       params = call.argument("params");
     }
     TCAgent.onEvent(context, eventID, eventLabel, params);
     break;
   case "setGlobalKV":
     String globalKey = call.argument("key");
     Object globalValue = call.argument("value");
     TCAgent.setGlobalKV(globalKey, globalValue);
     break;
   case "removeGlobalKV":
     String key = call.argument("key");
     TCAgent.removeGlobalKV(key);
     break;
   ```

   删除 `ios/Classes/TalkingDataAppAnalyticsPlugin.m` 文件中如下代码：

   ```objective-c
   else if ([@"onEvent" isEqualToString:call.method]){
           NSString * eventID = [self checkArgument:call.arguments forKey:@"eventID" ofType:[NSString class]];
           NSString * eventLabel = [self checkArgument:call.arguments forKey:@"eventLabel" ofType:[NSString class]];
           NSDictionary * params = [self checkArgument:call.arguments forKey:@"params" ofType:[NSDictionary class]];
           if (eventID) {
               [TalkingData trackEvent:eventID label:eventLabel parameters:params];
           }
       }
   ...
   else if ([@"setGlobalKV" isEqualToString:call.method]) {
           NSString * key = [self checkArgument:call.arguments forKey:@"key" ofType:[NSString class]];
           id value = call.arguments[@"value"];
           if (value) {
               [TalkingData setGlobalKV:key value:value];
           }
       }else if ([@"removeGlobalKV" isEqualToString:call.method]){
           NSString * key = [self checkArgument:call.arguments forKey:@"key" ofType:[NSString class]];
           [TalkingData removeGlobalKV:key];
       }
   
   ```

   b) 未选择 `标准化事件分析` 功能则删除以下4部分

   删除 `lib/talkingdata_appanalytics_plugin.dart` 文件中如下代码:

   ```dart
   static Future<void> onPlaceOrder({String orderID,int amount,String currencyType}) async{
     ...
   }
   
   static Future<void> onOrderPaySucc({String orderID,int amount,String currencyType,String payType}) async{
     ...
   }
   
   static Future<void> onCancelOrder({String orderID,int amount,String currencyType}) async{
     ...
   }
   
   static Future<void> onAddItemToShoppingCart({String itemId, String category, String name, int unitPrice, int amount}) async{
     ...
   }
   
   static Future<void> onViewItem({String itemId ,String category,String name,int unitPrice}) async{
     ...
   }
   
   static Future<void> onViewShoppingCart(ShoppingCart shoppingCart) async{
     ...
   }
   ...
     
   class ShoppingCart{
     ...
   }
   ```

   删除 `android/src/main/java/com/talkingdata/plugin/appanalytics/TalkingDataAppAnalyticsPlugin.java` 文件中如下代码：

   ```java
   case "onPlaceOrder":
     TCAgent.onPlaceOrder(
             (String) call.argument("orderId"),
             (int) call.argument("amount"),
       			(String) call.argument("currencyType")
     );
     break;
   case "onCancelOrder":
     TCAgent.onCancelOrder(
             (String) call.argument("orderId"),
             (int) call.argument("amount"),
       			(String) call.argument("currencyType")
     );
     break;
   case "onViewShoppingCart":
     ShoppingCart shoppingCart = ShoppingCart.createShoppingCart();
     List<Map> shoppingCartDetails = call.argument("shoppingCartDetails");
     for (int i = 0; i < shoppingCartDetails.size(); i++){
       Map map = shoppingCartDetails.get(i);
       shoppingCart.addItem(
               (String)map.get("itemID"),
               (String)map.get("category"),
               (String)map.get("name"),
               (int)map.get("unitPrice"),
               (int)map.get("amount")
       );
     }
   
     TCAgent.onViewShoppingCart(shoppingCart);
     break;
   case "onAddItemToShoppingCart":
     TCAgent.onAddItemToShoppingCart(
             (String) call.argument("itemID"),
             (String) call.argument("category"),
             (String) call.argument("name"),
             (int) call.argument("unitPrice"),
             (int) call.argument("amount")
     );
     break;
   case "onOrderPaySucc":
     TCAgent.onOrderPaySucc(
             (String) call.argument("orderId"),
             (int) call.argument("amount"),
       			(String) call.argument("currencyType"),
       			(String) call.argument("paymentType")
     );
     break;
   case "onViewItem":
     TCAgent.onViewItem(
             (String) call.argument("itemID"),
             (String) call.argument("category"),
             (String) call.argument("name"),
             (int) call.argument("unitPrice")
    );
     break;

   ...
     
   private Order getOrderFromFlutter(MethodCall call){
     ...
   }
   ```
   
   删除 `ios/Classes/TalkingDataAppAnalyticsPlugin.m` 文件中如下代码：
   
   ```objective-c
   else if ([@"onViewItem" isEqualToString:call.method]){
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
       }  else if ([@"onPlaceOrder" isEqualToString:call.method]){
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
   
       }
   ```



    c) 未选择`页面统计`功能则删除以下4部分

   删除 `lib/talkingdata_appanalytics_plugin.dart` 文件中如下代码:

   ```dart
   static Future<void> onPageStart(String pageName) async{
     return await _channel.invokeMethod('onPageStart', <String, dynamic>{
       'pageName': pageName
     });
   }
   
   static Future<void> onPageEnd(String pageName) async{
     return await _channel.invokeMethod('onPageEnd', <String, dynamic>{
       'pageName': pageName
     });
   }
   ```

    删除 `android/src/main/java/com/talkingdata/plugin/appanalytics/TalkingDataAppAnalyticsPlugin.java` 文件中如下代码：

   ```java
   case "onPageStart":
     TCAgent.onPageStart(context, (String) call.argument("pageName"));
     break;
   case "onPageEnd":
     TCAgent.onPageEnd(context, (String) call.argument("pageName"));
   	break;
   ```

删除 `ios/Classes/TalkingDataAppAnalyticsPlugin.m` 文件中如下代码：

```objective-c
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
    } else 
```



## 接口说明

**getDeviceID**

获取设备ID

**参数：**无

**示例：**

```dart
String deviceID;
_setDeviceID() async{
  deviceID =  await TalkingDataAppAnalytics.getDeviceID();
  //Print deviceID or dosomething
  print(deviceID);
}
```

---

**getOAID**

获取OAID。需要注意的是，这个接口建议您在初始化SDK之后的3-5秒再去调用，以避免您获取到null值

**参数：**无

**示例：**

```dart
String oaid;

Future.delayed(Duration(seconds:3),(){
 		_setOAID();
});

_setOAID() async{
   oaid =  await TalkingDataAppAnalytics.getOAID();
}
```

---

**onPageStart**

触发页面事件，在页面加载完毕的时候调用，用于记录页面名称和使用时长，和 `onPageEnd` 配合使用

**参数：**

| 名称     | 类型   | 说明     |
| :------- | ------ | -------- |
| pageName | String | 页面名称 |

**示例：**

```dart
TalkingDataAppAnalytics.onPageStart('Page Test');
```

---

**onPageEnd**

触发页面事件，在页面消失的时候调用，用于记录页面名称和使用时长，和 `onPageStart` 配合使用

**参数：**

| 名称     | 类型   | 说明     |
| :------- | ------ | -------- |
| pageName | String | 页面名称 |

**示例：**

```dart
TalkingDataAppAnalytics.onPageEnd('Page Test');
```

------

**onEvent**

自定义事件用于追踪任何需要了解的用户行为，如：用户点击某功能按钮、填写某个输入框、触发了某个广告等。

**参数：**

| 名称       | 类型   | 说明     |
| :--------- | ------ | -------- |
| eventID    | String | 事件名称 |
| eventLabel | String | 事件标签 |
| params     | Map    | 事件参数 |

**示例：**

```dart
Map map = {};
map['key1'] = 'value1';
map['key2'] = 'value2';
TalkingDataAppAnalytics.onEvent(
      eventID: 'TestEventID',
      eventLabel: 'TestEventLabel',
      params: map
);
```

------

**onEventWithValue**

  自定义事件用于追踪任何需要了解的用户行为，如：用户点击某功能按钮、填写某个输入框、触发了某个广告等。

  **参数：**

| 名称       | 类型   | 说明     |
| :--------- | ------ | -------- |
| eventID    | String | 事件名称 |
| eventLabel | String | 事件标签 |
| params     | Map    | 事件参数 |
| value      | double | 事件数值 |

  **示例：**

```dart
  Map map = {};
  map['key1'] = 'value1';
  map['key2'] = 'value2';
  TalkingDataAppAnalytics.onEvent(
        eventID: 'TestEventID',
      	eventLabel: 'TestEventLabel',
        params: map,
  			value:5.21
  );
```

---

**setGlobalKV**

设置自定义事件全局的key,value

**参数：**

| 名称  | 类型   | 说明        |
| :---- | ------ | ----------- |
| key   | String | 全局的key   |
| value | Object | 全局的value |

**示例：**

```dart
TalkingDataAppAnalytics.setGlobalKV('keyXXX','valueXXX');
TalkingDataAppAnalytics.setGlobalKV('keyXXX',12221);
```

------

**removeGlobalKV**

移除自定义事件全局的key,value

**参数：**

| 名称 | 类型   | 说明      |
| :--- | ------ | --------- |
| key  | String | 全局的key |

**示例：**

```dart
TalkingDataAppAnalytics.removeGlobalKV('keyXXX');
```

------

**onRegister**

注册接口用于记录用户在使用应用过程中的注册行为。建议在注册成功时调用此接口。

**参数：**

| 名称        | 类型        | 说明     |
| :---------- | ----------- | -------- |
| profileID   | String      | 账户ID   |
| profileType | ProfileType | 账户类型 |
| name        | String      | 账户昵称 |

**示例：**

```dart
TalkingDataAppAnalytics.onRegister(
   profileID: 'TestProfileID',
   profileType: ProfileType.WEIXIN,
   name: 'testName'
);
```

------

**onLogin**

登录接口用于记录用户在使用应用过程中的登录行为。

**参数：**

| 名称        | 类型        | 说明     |
| :---------- | ----------- | -------- |
| profileID   | String      | 账户ID   |
| profileType | ProfileType | 账户类型 |
| name        | String      | 账户昵称 |

**示例：**

```dart
TalkingDataAppAnalytics.onLogin(
   profileID: 'TestProfileID',
   profileType: ProfileType.WEIXIN,
   name: 'testName'
);
```

------

**onPlaceOrder**

> 下单的接口现在已经做了变更，原有的接口已经不建议使用，请开发者尽快更新
>

下单接口用于记录用户在使用应用过程中的成功下单的行为。

**参数：**

| 名称         | 类型   | 说明                                                         |
| :----------- | ------ | ------------------------------------------------------------ |
| orderID      | String | 订单ID，JS封装层无长度限制，静态库对于超过256个字符的部分会做截断处理，全局唯一，由开发者提供并维护（此ID很重要，如果不清楚集成时咨询客服）。<br/>用于唯一标识一次交易。以及后期系统之间对账使用！<br/>*如果多次充值成功的orderID重复，将只计算首次成功的数据，其他数据会认为重复数据丢弃。<br/>如果传入null或者空字符串""，则不产生下单事件。 |
| amount       | int    | 订单的总金额，货币单位为分，币种见currrencyType。            |
| currencyType | String | 订单的货币类型。<br/>请使用国际标准组织 ISO4217 中规范的3位字母代码标记货币类型。例：人民币 CNY；美元 USD；欧元 EUR；<br/>如果您使用其他自定义等价物作为现金，亦可使用 ISO4217 中没有的3位字母组合传入货币型，我们会在报表页面中提供汇率设定功能 |

**示例：**

```dart
  TalkingDataAppAnalytics.onPlaceOrder(
    orderID: 'order01',//订单ID
    amount: 22120,//总价格
    currencyType: 'CNY'//货币类型
  );
```

------

**onOrderPaySucc**

> 成功支付订单的接口现在已经做了变更，原有的接口已经不建议使用，请开发者尽快更新

成功支付订单接口用于记录用户完成订单支付的行为。

**参数：**

| 名称      | 类型   | 说明     |
| :----------- | ------ | ------------------------------------------------------------ |
| orderID      | String | 订单ID，JS封装层无长度限制，静态库对于超过256个字符的部分会做截断处理，全局唯一，由开发者提供并维护（此ID很重要，如果不清楚集成时咨询客服）。<br/>用于唯一标识一次交易。以及后期系统之间对账使用！<br/>*如果多次充值成功的orderID重复，将只计算首次成功的数据，其他数据会认为重复数据丢弃。<br/>如果传入null或者空字符串""，则不产生下单事件。 |
| amount       | int    | 订单的总金额，货币单位为分，币种见currrencyType。            |
| currencyType | String | 订单的货币类型。<br/>请使用国际标准组织 ISO4217 中规范的3位字母代码标记货币类型。例：人民币 CNY；美元 USD；欧元 EUR；<br/>如果您使用其他自定义等价物作为现金，亦可使用 ISO4217 中没有的3位字母组合传入货币型，我们会在报表页面中提供汇率设定功能 |
| paymentType | String | 支付类型，如：支付宝、Alipay、微信等，最多 16 个字符。 |

**示例：**

```dart
TalkingDataAppAnalytics.onOrderPaySucc(
    orderID: 'order01',//订单ID
    amount: 22120,//总价格
    currencyType: 'CNY',//货币类型
    paymentType: 'Alipay'//支付类型
);
```

------

**onCancelOrder**

取消订单接口用于记录用户在使用应用过程中的取消下单的行为。

**参数：**

| 名称         | 类型   | 说明                                                         |
| :----------- | ------ | ------------------------------------------------------------ |
| orderID      | String | 订单ID，JS封装层无长度限制，静态库对于超过256个字符的部分会做截断处理，全局唯一，由开发者提供并维护（此ID很重要，如果不清楚集成时咨询客服）。<br/>用于唯一标识一次交易。以及后期系统之间对账使用！<br/>*如果多次充值成功的orderID重复，将只计算首次成功的数据，其他数据会认为重复数据丢弃。<br/>如果传入null或者空字符串""，则不产生下单事件。 |
| amount       | int    | 订单的总金额，货币单位为分，币种见currrencyType。            |
| currencyType | String | 订单的货币类型。<br/>请使用国际标准组织 ISO4217 中规范的3位字母代码标记货币类型。例：人民币 CNY；美元 USD；欧元 EUR；<br/>如果您使用其他自定义等价物作为现金，亦可使用 ISO4217 中没有的3位字母组合传入货币型，我们会在报表页面中提供汇率设定功能 |

**示例：**

```dart
  TalkingDataAppAnalytics.onCancelOrder(
    orderID: 'order01',//订单ID
    amount: 22120,//总价格
    currencyType: 'CNY'//货币类型
  );
```

------

**onAddItemToShoppingCart**

用于记录用户将商品加入购物车的行为。

**参数：**

| 名称      | 类型   | 说明     |
| :-------- | ------ | -------- |
| itemId    | String | 商品ID   |
| category  | String | 商品类别 |
| name      | String | 商品名称 |
| unitPrice | int    | 商品单价 |
| amount    | int    | 商品数量 |

**示例：**

```dart
TalkingDataAppAnalytics.onAddItemToShoppingCart(
  itemId: 'itemID331135516',
  category: 'Food',
  name: 'apple',
  unitPrice: 22,
  amount: 33
);
```

------

**onViewItem**

用于描述用户查看商品详情的行为。

**参数：**

| 名称      | 类型   | 说明     |
| :-------- | ------ | -------- |
| itemId    | String | 商品ID   |
| category  | String | 商品类别 |
| name      | String | 商品名称 |
| unitPrice | int    | 商品单价 |

**示例：**

```dart
TalkingDataAppAnalytics.onViewItem(
  itemId: 'itemID331135516',
  category: 'Food',
  name: 'apple',
  unitPrice: 44
);
```

------

**onViewShoppingCart**

用于描述用户查看商品详情的行为。

**参数：**

| 名称         | 类型         | 说明       |
| :----------- | ------------ | ---------- |
| shoppingCart | ShoppingCart | 购物车信息 |

**示例：**

```dart
ShoppingCart shoppingCart = ShoppingCart();
shoppingCart.addItem(
  'itemID331135516', 		//商品ID
  'Food', 							//商品类别
  'apple', 							//商品名称
  33, 									//商品单价
  11										//商品数量
);
shoppingCart.addItem('itemID333103428', 'Food', 'banana', 777, 888);
TalkingDataAppAnalytics.onViewShoppingCart(shoppingCart);

```

------

## 运行Demo

连接真机。终端运行：

```shell
cd sdk-talkingdata-sdk-flutter-plugin/example
flutter run
```

