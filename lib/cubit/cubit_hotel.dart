import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myhotx/api/api_manager.dart';
import 'package:myhotx/api/api_payload.dart';
import 'package:myhotx/api/api_request.dart';
import 'package:myhotx/api/common.dart';
import 'package:myhotx/cubit/common_state.dart';
import 'package:myhotx/model/popular_stay_model.dart';

class HotalListCubit extends Cubit<CommonState> {
  HotalListCubit({required this.context}) : super(CommonState.initial);
  BuildContext context;

  ValueNotifier<List<Property>> hotalListNotifier = ValueNotifier([]);
  ValueNotifier<bool> hasMoreNotifier = ValueNotifier(true);
  ValueNotifier<bool> isLoadingMoreNotifier = ValueNotifier(false);

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isInitialLoad = true;

  void getHotelList(
    BuildContext context, [
    logDate = '',
    isLoader = true,
    bool isLoadMore = false,
  ]) async {
    if (!isLoadMore) {
      _currentPage = 1;
      _isInitialLoad = true;
      hasMoreNotifier.value = true;
    }

    if (await muIsNetworkAvailable()) {
      try {
        if (isLoader && !isLoadMore)
          GlobalLoader().show(context, message: 'Please wait...');
        if (isLoadMore) isLoadingMoreNotifier.value = true;

        ResponseMdl responseMdl = await ApiRequest.inst.postApiRequest(
          url: ApiManager.inst.userAppUrl,
          header: <String, String>{
            'authtoken': "71523fdd8d26f585315b4233e39d9263",
            'visitortoken': "a0c4-32d6-310c-c71b-8308-2b85-b936-5af3",
            'Content-Type': 'application/json',
          },
          payload: await ApiPayload.inst.popularStayPayload(
            country: "India",
            state: "Uttarakhand",
            city: "India",
            page: _currentPage,
            limit: _pageSize,
          ),
        );

        if (responseMdl.isSuccess) {
          responseMdl.data = responseMdl.data;

          List<Property> newProperties = [];

          if (responseMdl.data is List) {
            newProperties = (responseMdl.data as List)
                .map((e) => Property.fromJson(e))
                .toList();
          } else if (responseMdl.data['data'] is List) {
            newProperties = (responseMdl.data['data'] as List)
                .map((e) => Property.fromJson(e))
                .toList();
          }

          // Check if we have more data
          if (newProperties.length < _pageSize) {
            hasMoreNotifier.value = false;
          }

          if (isLoadMore) {
            hotalListNotifier.value = [
              ...hotalListNotifier.value,
              ...newProperties,
            ];
          } else {
            hotalListNotifier.value = newProperties;
          }

          _currentPage++;

          _isInitialLoad = false;
        } else {
          if (isLoadMore) {
            hasMoreNotifier.value = false;
          }
        }
      } catch (ex) {
        logError(name: 'HotelCubit/getData', msg: '$ex');
        if (isLoadMore) {
          hasMoreNotifier.value = false;
        }
      } finally {
        if (isLoader && !isLoadMore && context.mounted) GlobalLoader().hide();
        if (isLoadMore) isLoadingMoreNotifier.value = false;
      }
    }
  }

  void loadMore() {
    if (!hasMoreNotifier.value || isLoadingMoreNotifier.value || _isInitialLoad)
      return;
    getHotelList(context, '', false, true);
  }

  void refresh() {
    _currentPage = 1;
    hasMoreNotifier.value = true;
    getHotelList(context, '', false, false);
  }
}
