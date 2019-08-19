import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fun_android/ui/widget/theme.dart';
import 'package:fun_android/config/storage_manager.dart';

//const Color(0xFF5394FF),

class ThemeModel with ChangeNotifier {
  static const kThemeColorIndex = 'kThemeColorIndex';
  static const kThemeBrightnessIndex = 'kThemeBrightnessIndex';
  static const kFontIndex = 'kFontIndex';

  static const fontNameList = ['跟随系统', '快乐字体'];
  static const fontValueList = ['system', 'kuaile'];

  ThemeData _themeData;

  /// 明暗模式
  Brightness _brightness;

  /// 当前主题颜色
  MaterialColor _themeColor;

  /// 当前字体索引
  int _fontIndex;

  ThemeModel() {
    /// 明暗模式
    _brightness = Brightness.values[
        StorageManager.sharedPreferences.getInt(kThemeBrightnessIndex) ?? 0];

    /// 获取主题色
    _themeColor = Colors.primaries[
        StorageManager.sharedPreferences.getInt(kThemeColorIndex) ?? 0];

    /// 获取字体
    _fontIndex = StorageManager.sharedPreferences.getInt(kFontIndex) ?? 0;
    _generateThemeData();
  }

  ThemeData get themeData => _themeData;

  ThemeData get darkTheme => _themeData.copyWith(brightness: Brightness.dark);

  int get fontIndex => _fontIndex;

  /// 切换指定色彩
  ///
  /// 没有传[brightness]就不改变brightness,color同理
  void switchTheme({Brightness brightness, MaterialColor color}) {
    _brightness = brightness ?? _brightness;
    _themeColor = color ?? _themeColor;
    _generateThemeData();
    notifyListeners();
    saveTheme2Storage(_brightness, _themeColor);
  }

  /// 随机一个主题色彩
  ///
  /// 可以指定明暗模式,不指定则保持不变
  void switchRandomTheme({Brightness brightness}) {
    brightness ??= (Random().nextBool() ? Brightness.dark : Brightness.light);
    int colorIndex = Random().nextInt(Colors.primaries.length - 1);
    switchTheme(brightness: brightness, color: Colors.primaries[colorIndex]);
  }

  /// 切换字体
  switchFont(int index) {
    _fontIndex = index;
    switchTheme();
    saveFontIndex(index);
  }

  /// 根据主题 明暗 和 颜色 生成对应的主题
  _generateThemeData() {
    var themeColor = _themeColor;
    var isDark = Brightness.dark == _brightness;
    var themeData = ThemeData(
        brightness: _brightness,

        /// 主题颜色属于亮色系还是属于暗色系(eg:dark时,AppBarTitle的颜色为白色,反之为黑色)
        primaryColorBrightness: Brightness.dark,
        accentColorBrightness: Brightness.dark,
        primarySwatch: themeColor,
        accentColor: isDark ? themeColor[700] : null,
        fontFamily: fontValueList[fontIndex]);

    themeData = themeData.copyWith(
      brightness: _brightness,
      accentColor: themeColor,
      appBarTheme: themeData.appBarTheme.copyWith(elevation: 0),
      splashColor: themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      errorColor: Colors.red,
      cursorColor: themeColor,
      textSelectionColor: themeColor.withAlpha(60),
      textSelectionHandleColor: themeColor.withAlpha(60),
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 10),
        labelStyle: themeData.textTheme.caption,
        backgroundColor: themeData.chipTheme.backgroundColor.withOpacity(0.1),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: themeColor,
          brightness: _brightness,
          textTheme: CupertinoTextThemeData(brightness: Brightness.light)),
      inputDecorationTheme: ThemeHelper.inputDecorationTheme(themeData),
    );

    _themeData = themeData;
  }

  /// 数据持久化到shared preferences
  saveTheme2Storage(Brightness brightness, MaterialColor themeColor) async {
    var index = Colors.primaries.indexOf(themeColor);
    await Future.wait([
      StorageManager.sharedPreferences
          .setInt(kThemeBrightnessIndex, brightness.index),
      StorageManager.sharedPreferences.setInt(kThemeColorIndex, index)
    ]);
  }

  /// 字体选择持久化
  static saveFontIndex(int index) async {
    await StorageManager.sharedPreferences.setInt(kFontIndex, index);
  }
}
