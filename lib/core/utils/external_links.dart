import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/widgets.dart';

/// The pages the app has to link to. Apple and Google both refuse an app that
/// hides its privacy policy, and Apple also requires a way to delete the
/// account from inside the app - here that is a link to the website, which is
/// where the deletion actually happens.
class AppLinks {
  const AppLinks._();

  static const privacy = 'https://funduqiplus.com/ar/privacy';
  static const terms = 'https://funduqiplus.com/ar/terms';
  static const support = 'https://funduqiplus.com/ar/support';
  static const deleteAccount = 'https://funduqiplus.com/ar/delete-account';
}

/// Opens [url] in the phone's browser, outside the app. Never throws: a phone
/// with no browser, or a link the system refuses, only shows a toast.
Future<void> openExternal(BuildContext context, String url) async {
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    showNzToast(context, 'تعذّر فتح الرابط. افتح funduqiplus.com في المتصفح.');
  }
}
