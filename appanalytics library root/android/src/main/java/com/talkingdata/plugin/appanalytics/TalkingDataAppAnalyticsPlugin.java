package com.talkingdata.plugin.appanalytics;

import android.content.Context;

import com.tendcloud.tenddata.ShoppingCart;
import com.tendcloud.tenddata.TCAgent;
import com.tendcloud.tenddata.TDProfile;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** TalkingDataAppAnalyticsPlugin */
public class TalkingDataAppAnalyticsPlugin implements MethodCallHandler {
  private Context context;

  private TalkingDataAppAnalyticsPlugin(Context context){
    this.context = context;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "TalkingData_AppAnalytics");
    channel.setMethodCallHandler(new TalkingDataAppAnalyticsPlugin(registrar.context().getApplicationContext()));
  }

  public static void init(Context ctx, String appID, String channelID) {
    TCAgent.init(ctx, appID, channelID);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method){
      case "init":
        TCAgent.init(context,(String) call.argument("appID"),(String) call.argument("channelID"));
        break;
      case "getDeviceID":
        result.success(TCAgent.getDeviceId(context));
        break;
      case "getOAID":
        result.success(TCAgent.getOAID(context));
        break;
      case "onPageStart":
        TCAgent.onPageStart(context, (String) call.argument("pageName"));
        break;
      case "onPageEnd":
        TCAgent.onPageEnd(context, (String) call.argument("pageName"));
        break;
      case "onEvent":
        String eventID = call.argument("eventID");
        String eventLabel = call.argument("eventLabel");
        Map params = null;
        if (call.argument("params") instanceof Map){
          params = call.argument("params");
        }
        TCAgent.onEvent(context, eventID, eventLabel, params);
        break;
      case "onEventWithValue":
        Map paramWith = null;
        if (call.argument("params") instanceof Map){
          paramWith = call.argument("params");
        }
        TCAgent.onEvent(context,
                (String)call.argument("eventID"),
                (String)call.argument("eventLabel"),
                paramWith,
                (double)call.argument("value"));
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
      case "onRegister":
        String profileID = call.argument("profileID");
        String profileType = call.argument("profileType");
        String name = call.argument("name");
        TCAgent.onRegister(profileID, TDProfile.ProfileType.valueOf(profileType), name);
        break;
      case "onLogin":
        profileID = call.argument("profileID");
        profileType = call.argument("profileType");
        name = call.argument("name");
        TCAgent.onLogin(profileID, TDProfile.ProfileType.valueOf(profileType), name);
        break;
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
      default:
        result.notImplemented();
        break;
    }
  }
}
