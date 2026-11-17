package com.funduqiplus.app

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity, not FlutterActivity: local_auth's fingerprint
// prompt is a fragment and needs it.
class MainActivity : FlutterFragmentActivity()
