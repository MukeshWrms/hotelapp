import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myhotx/api/api_manager.dart';

import 'package:myhotx/api/api_request.dart';
import 'package:myhotx/api/common.dart';
import 'package:myhotx/cubit/common_state.dart';

import 'package:myhotx/model/search_hotel.dart';

class HotalSearchListCubit extends Cubit<CommonState> {
  HotalSearchListCubit({required this.context}) : super(CommonState.initial);
  BuildContext context;

  ValueNotifier<List<PropertySearch>> hotalSearchListNotifier = ValueNotifier(
    [],
  );
  ValueNotifier<bool> hasSearchMoreNotifier = ValueNotifier(true);
  ValueNotifier<bool> isLoadingSearchMoreNotifier = ValueNotifier(false);

  int _currentPage = 1;
  final int _pageSize = 5;
  bool _isInitialLoad = true;
  Map<String, dynamic>? _currentPayload;
  bool _isLoading = false;

  void loadMore() {
    if (!hasSearchMoreNotifier.value ||
        isLoadingSearchMoreNotifier.value ||
        _isInitialLoad ||
        _currentPayload == null ||
        _isLoading) {
      print('Load more blocked - conditions not met');
      return;
    }

    print('Loading more data... Page: $_currentPage');

    //call
    getBookingHotelList(
      context,
      payload: _currentPayload!,
      isLoader: false,
      isLoadMore: true,
    );
  }

  void refresh() {
    _currentPage = 1;
    hasSearchMoreNotifier.value = true;
    _isInitialLoad = true;
    if (_currentPayload != null) {
      getBookingHotelList(
        context,
        payload: _currentPayload!,
        isLoader: false,
        isLoadMore: false,
      );
    }
  }

  //get the search result
  void getBookingHotelList(
    BuildContext context, {
    logDate = '',
    required Map<String, dynamic> payload,
    isLoader = true,
    bool isLoadMore = false,
  }) async {
    if (_isLoading) {
      print('Already loading, skipping...');
      return;
    }

    if (!isLoadMore) {
      _currentPage = 1;
      _isInitialLoad = true;
      hasSearchMoreNotifier.value = true;
      _currentPayload = payload;
    }

    if (await muIsNetworkAvailable()) {
      try {
        _isLoading = true;

        if (isLoader && !isLoadMore)
          GlobalLoader().show(context, message: 'Please wait...');
        if (isLoadMore) isLoadingSearchMoreNotifier.value = true;

        // Add pagination parameters to payload
        final updatedPayload = Map<String, dynamic>.from(payload);
        updatedPayload['page'] = _currentPage;
        updatedPayload['limit'] = _pageSize;

        ResponseMdl responseMdl = await ApiRequest.inst.postApiRequest(
          url: ApiManager.inst.userAppUrl,
          header: <String, String>{
            'authtoken': "71523fdd8d26f585315b4233e39d9263",
            'visitortoken': "a0c4-32d6-310c-c71b-8308-2b85-b936-5af3",
            'Content-Type': 'application/json',
          },
          payload: updatedPayload,
        );

        print('Response success: ${responseMdl.isSuccess}');

        if (responseMdl.isSuccess && responseMdl.data != null) {
          List<PropertySearch> newProperties = [];

          if (responseMdl.data['data'] != null &&
              responseMdl.data['data']['arrayOfHotelList'] is List) {
            newProperties =
                (responseMdl.data['data']['arrayOfHotelList'] as List)
                    .map((e) => PropertySearch.fromJson(e))
                    .toList();
          } else if (responseMdl.data['arrayOfHotelList'] is List) {
            newProperties = (responseMdl.data['arrayOfHotelList'] as List)
                .map((e) => PropertySearch.fromJson(e))
                .toList();
          } else if (responseMdl.data is List) {
            newProperties = (responseMdl.data as List)
                .map((e) => PropertySearch.fromJson(e))
                .toList();
          } else if (responseMdl.data['data'] is List) {
            newProperties = (responseMdl.data['data'] as List)
                .map((e) => PropertySearch.fromJson(e))
                .toList();
          }

          if (newProperties.length < _pageSize) {
            hasSearchMoreNotifier.value = false;
            print(
              '🚫 No more data available. Received ${newProperties.length} but expected $_pageSize',
            );
          } else {
            // print('✅ More data available');
          }

          if (isLoadMore && newProperties.isNotEmpty) {
            final currentList = hotalSearchListNotifier.value;
            hotalSearchListNotifier.value = [...currentList, ...newProperties];
            print(
              'Appended ${newProperties.length} items. Total: ${hotalSearchListNotifier.value.length}',
            );
          } else if (!isLoadMore) {
            hotalSearchListNotifier.value = newProperties;
            print(' Initial load: ${newProperties.length} items');
          }

          if (newProperties.isNotEmpty) {
            _currentPage++;
            print('📄 Page incremented to: $_currentPage');
          }

          _isInitialLoad = false;
        } else {
          print('❌ API call failed or no data');
          if (isLoadMore) {
            hasSearchMoreNotifier.value = false;
          }
        }
      } catch (ex) {
        print('Error: $ex');
        logError(name: 'HotelCubit/getData', msg: '$ex');
        if (isLoadMore) {
          hasSearchMoreNotifier.value = false;
        }
      } finally {
        _isLoading = false;
        if (isLoader && !isLoadMore && context.mounted) GlobalLoader().hide();
        if (isLoadMore) isLoadingSearchMoreNotifier.value = false;
      }
    } else {
      print('No internet connection');
      _isLoading = false;
    }
  }

  String getPropertyImageUrl(PropertySearch property) {
    return property.propertyImage?.fullUrl ?? '';
  }

  String getDisplayPrice(PropertySearch property) {
    return property.propertyMinPrice?.displayAmount ?? 'N/A';
  }

  bool hasFreeWifi(PropertySearch property) {
    return property.propertyPoliciesAndAmmenities?.data?.freeWifi ?? false;
  }

  bool hasFreeCancellation(PropertySearch property) {
    return property.propertyPoliciesAndAmmenities?.data?.freeCancellation ??
        false;
  }

  bool isCoupleFriendly(PropertySearch property) {
    return property.propertyPoliciesAndAmmenities?.data?.coupleFriendly ??
        false;
  }

  String getLocationString(PropertySearch property) {
    final address = property.propertyAddress;
    if (address == null) return '';
    return '${address.city}, ${address.state}, ${address.country}';
  }

  double getRating(PropertySearch property) {
    return property.googleReview?.data?.overallRating ?? 0.0;
  }

  int getReviewCount(PropertySearch property) {
    return property.googleReview?.data?.totalUserRating ?? 0;
  }

  void clearSearch() {
    hotalSearchListNotifier.value = [];
    _currentPage = 1;
    hasSearchMoreNotifier.value = true;
    _isInitialLoad = true;
    _currentPayload = null;
    _isLoading = false;
  }
}
