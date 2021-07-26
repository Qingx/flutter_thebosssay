import 'package:rxdart/rxdart.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class TalkingApi {
  TalkingApi._();

  static TalkingApi _mIns;

  factory TalkingApi.ins() => _mIns ??= TalkingApi._();

  ///获取设备id
  Observable<String> obtainDeviceId() {
    return Observable.fromFuture(TalkingDataAppAnalytics.getDeviceID());
  }

  ///onPageStart:触发页面事件，在页面加载完毕的时候调用，用于记录页面名称和使用时长
  void obtainPageStart(String pageName) {
    TalkingDataAppAnalytics.onPageStart(pageName);
  }

  ///onPageEnd:触发页面事件，在页面消失的时候调用，用于记录页面名称和使用时长
  void obtainPageEnd(String pageName) {
    TalkingDataAppAnalytics.onPageEnd(pageName);
  }

  ///onRegister:注册接口用于记录用户在使用应用过程中的注册行为
  void obtainRegister(String tempId) {
    TalkingDataAppAnalytics.onRegister(
        profileID: tempId, profileType: ProfileType.TYPE1, name: "游客");
  }

  ///onLogin:注登录接口用于记录用户在使用应用过程中的登录行为
  void obtainLogin(String userId) {
    TalkingDataAppAnalytics.onLogin(
        profileID: userId, profileType: ProfileType.TYPE2, name: "正式");
  }

  ///onEvent:事件接口用于记录用户在使用应用过程中的热点行为
  void obtainEvent(String eventId, String label, Map map) {
    TalkingDataAppAnalytics.onEvent(
        eventID: eventId, eventLabel: "ProfileType.TYPE2", params: map);
  }
}
