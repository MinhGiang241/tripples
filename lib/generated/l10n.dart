// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Welcome to`
  String get welcome_to {
    return Intl.message(
      'Welcome to',
      name: 'welcome_to',
      desc: '',
      args: [],
    );
  }

  /// `Let's start`
  String get let_us_start {
    return Intl.message(
      'Let\'s start',
      name: 'let_us_start',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get login {
    return Intl.message(
      'Đăng nhập',
      name: 'log_in',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signup {
    return Intl.message(
      'Đăng ký',
      name: 'signup',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logout {
    return Intl.message(
      'Đăng xuất',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Mật khẩu',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `You don't have an account?`
  String get noAccount {
    return Intl.message(
      'Bạn không có mật khẩu',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Tên',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirm_pass {
    return Intl.message(
      'Xác nhận mật khẩu',
      name: 'confirm_pass',
      desc: '',
      args: [],
    );
  }

  /// `Inspections`
  String get inspections {
    return Intl.message(
      'Inspections',
      name: 'inspections',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get templates {
    return Intl.message(
      'Đang xử lý',
      name: 'templates',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get inprogress_complete {
    return Intl.message(
      'Hoàn thành',
      name: 'inprogress_complete',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Tìm kiếm',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Chi tiết',
      name: 'Chi tiết',
      desc: '',
      args: [],
    );
  }

  /// `Campaign description`
  String get campaign_description {
    return Intl.message(
      'Mô tả chiến dịch',
      name: 'campaign_description',
      desc: '',
      args: [],
    );
  }

  /// `Customer`
  String get customer {
    return Intl.message(
      'Khách hàng',
      name: 'Khách hàng',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get branch {
    return Intl.message(
      'Chi nhánh',
      name: 'Chi nhánh',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Địa chỉ',
      name: 'Địa chỉ',
      desc: '',
      args: [],
    );
  }

  /// `Working time`
  String get working_time {
    return Intl.message(
      'Working time',
      name: 'working_time',
      desc: '',
      args: [],
    );
  }

  /// `Begin`
  String get begin {
    return Intl.message(
      'Bắt đầu',
      name: 'Bắt đầu',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get end {
    return Intl.message(
      'Kết thúc',
      name: 'Kết thúc',
      desc: '',
      args: [],
    );
  }

  /// `Select file`
  String get select_file {
    return Intl.message(
      'Chọn file',
      name: 'Chọn file',
      desc: '',
      args: [],
    );
  }

  /// `Upload file`
  String get upload_file {
    return Intl.message(
      'Upload file',
      name: 'upload_file',
      desc: '',
      args: [],
    );
  }

  /// `Image/Video`
  String get image_video {
    return Intl.message(
      'Hình ảnh/Video',
      name: 'Hình ảnh/Video',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message(
      'File',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `Choose File`
  String get choose_file {
    return Intl.message(
      'Chọn file',
      name: 'Chọn file',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Gửi',
      name: 'Gửi',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get user_name {
    return Intl.message(
      'Tên tài khoản',
      name: 'Tên tài khoản',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Kết quả',
      name: 'Kết quả',
      desc: '',
      args: [],
    );
  }

  /// `Survey`
  String get survey {
    return Intl.message(
      'Khảo sát',
      name: 'Khảo sát',
      desc: '',
      args: [],
    );
  }

  /// `Can not be empty!`
  String get not_blank {
    return Intl.message(
      'Không để trống trường này.',
      name: 'Không để trống trường này.',
      desc: '',
      args: [],
    );
  }

  /// `Password does not match.`
  String get not_same {
    return Intl.message(
      'Mật khẩu không trùng khớp.',
      name: 'Mật khẩu không trùng khớp.',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phone {
    return Intl.message(
      'Số điện thoại',
      name: 'Số điện thoại',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
