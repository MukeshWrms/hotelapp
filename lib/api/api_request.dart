import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

import 'package:myhotx/api/common.dart';

/*
status 0 Fail;
status 1 Success;
status 2 Session Expired;
*/

class ResponseMdl {
  bool isSuccess;
  Map<String, dynamic> data;
  ResponseMdl({this.isSuccess = false, this.data = const {}});
  Map<String, dynamic> toMap() {
    return {'isSuccess': isSuccess, 'data': data};
  }
}

class ApiRequest {
  static ApiRequest inst = ApiRequest();
  http.Client _client = http.Client();
  // dynamic postApiRequest({
  Future<ResponseMdl> postApiRequest({
    String url = '',
    Map payload = const {},
    Map<String, String> header = const {},
  }) async {
    try {
      logInfo(name: 'POST URL', msg: url);
      logInfo(name: 'Payload', msg: jsonEncode(payload));
      /*API REQUEST*/
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: header,
      );
      logInfo(name: "ResponseApi", msg: response.body.toString());
      logInfo(name: "ResponseUrl", msg: url);
      /*CHECK STATUS CODE*/
      if (response.statusCode == 200) {
        logInfo(name: "ResponseData", msg: response.body);

        final Map<String, dynamic> jsonBody = jsonDecode(response.body);

        /*Dynamically check success OR status OR responseCode*/
        bool successFlag = false;
        if (jsonBody.containsKey('success')) {
          successFlag = jsonBody['success'] == true;
        } else if (jsonBody.containsKey('status')) {
          successFlag = jsonBody['status'] == true;
        } else if (jsonBody.containsKey('responseCode')) {
          successFlag = jsonBody['responseCode'] == 200;
        }

        ResponseMdl responseMdl = ResponseMdl(
          // isSuccess: true,
          isSuccess: successFlag,
          data: jsonDecode(response.body),
        );

        return responseMdl;
      }
      if (response.statusCode == 201) {
        logInfo(name: "ResponseData", msg: response.body);
        ResponseMdl responseMdl = ResponseMdl(
          isSuccess: true,
          data: jsonDecode(response.body),
        );
        if (responseMdl.data['success']) {
          return responseMdl;
        } else {
          toastMsg('login failed! Invalid User Name and password..');
        }
        // return response.body.toString();
      } else if (response.statusCode == 401) {
        debugPrint('responseMdl_UNAUTHORISED');
      }
    } on SocketException catch (ex) {
      // toastMsg(muSetText('ServerError', 'Server Error'));
      debugPrint('responseMdl_SocketException $ex');
    } on http.ClientException catch (ex) {
      // toastMsg(muSetText('network_not_available', 'network_not_available'));
      debugPrint('responseMdl_ClientException $ex');
    } catch (ex) {
      debugPrint('responseMdl_EXCEPTION $ex');
    }
    return ResponseMdl();
  }
}
