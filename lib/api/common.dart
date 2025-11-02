import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

toastMsgCancel() {
  Fluttertoast.cancel();
}

toastMsg(String value) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: value,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 12.0,
  );
}

Future<bool> muIsNetworkAvailable() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    } else {
      toastMsg('Network not Available');
      return false;
    }
  } on SocketException {
    toastMsg('Network not Available');
    return false;
  }
}

class GlobalLoader {
  static final GlobalLoader _instance = GlobalLoader._internal();
  factory GlobalLoader() => _instance;
  GlobalLoader._internal();

  OverlayEntry? _overlayEntry;

  void show(BuildContext context, {String message = "Loading..."}) {
    if (_overlayEntry != null) return; // Avoid duplicate overlays

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(dismissible: false, color: Colors.black54),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitCircle(color: Colors.red, size: 50),
                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ).copyWith(decoration: TextDecoration.none),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

void logInfo({required String name, required String msg}) {
  log('\x1B[33m$msg\x1B[0m', name: '\x1B[37m$name\x1B[0m');
}

/*String logModelList({ dynamic list}) {
  return jsonEncode(list.map((e) => e.toMap()).toList());
}*/
void logSuccess({required String name, required String msg}) {
  log('\x1B[32m$msg\x1B[0m', name: '\x1B[37m$name\x1B[0m');
}

void logError({required String name, required String msg}) {
  // Try to infer caller name if not provided
  String caller = name;

  // Tag logs with caller info
  final logTag = '[ERROR][$caller]';

  print('$logTag ❌ ExceptionAt: $name');
}
