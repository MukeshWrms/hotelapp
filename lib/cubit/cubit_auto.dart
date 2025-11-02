import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myhotx/api/api_manager.dart';
import 'package:myhotx/api/api_payload.dart';
import 'package:myhotx/api/api_request.dart';
import 'package:myhotx/api/coman.dart';
import 'package:myhotx/cubit/common_state.dart';
import 'package:myhotx/model/search_autocomplete_model.dart';

class AutoSearchListCubit extends Cubit<CommonState> {
  AutoSearchListCubit({required this.context}) : super(CommonState.initial);

  BuildContext context;

  ValueNotifier<List<SearchResult>> autoSearchListNotifier = ValueNotifier([]);

  List<SearchResult> searchList = [];

  Future<void> getAutoSearchList(
    BuildContext context, {
    required String queryX,
    bool isLoader = true,
  }) async {
    if (await muIsNetworkAvailable()) {
      try {
        if (isLoader) {
          GlobalLoader().show(context, message: 'Fetching results...');
        }

        ResponseMdl responseMdl = await ApiRequest.inst.postApiRequest(
          url: ApiManager.inst.userAppUrl,
          header: <String, String>{
            'authtoken': "71523fdd8d26f585315b4233e39d9263",
            'visitortoken': "a0c4-32d6-310c-c71b-8308-2b85-b936-5af3",
            'Content-Type': 'application/json',
          },
          payload: await ApiPayload.inst.searchAutoCompletePayload(
            inputText: queryX,
          ),
        );

        if (responseMdl.isSuccess && responseMdl.data != null) {
          final parsed = SearchAutoCompleteResponse.fromJson(responseMdl.data);

          // main data from response
          if (parsed.data != null) {
            final searchData = parsed.data!;
            final autoList = searchData.autoCompleteList;

            List<SearchResult> allResults = [];

            if (autoList.byPropertyName != null) {
              allResults.addAll(autoList.byPropertyName!.listOfResult);
            }
            if (autoList.byStreet != null) {
              allResults.addAll(autoList.byStreet!.listOfResult);
            }
            if (autoList.byCity != null) {
              allResults.addAll(autoList.byCity!.listOfResult);
            }
            if (autoList.byState != null) {
              allResults.addAll(autoList.byState!.listOfResult);
            }
            if (autoList.byCountry != null) {
              allResults.addAll(autoList.byCountry!.listOfResult);
            }

            // update lists
            searchList = allResults;
            autoSearchListNotifier.value = allResults;
          }
        }
      } catch (ex) {
        logError(name: 'AutoSearchListCubit/getAutoSearchList', msg: '$ex');
      } finally {
        if (isLoader && context.mounted) GlobalLoader().hide();
      }
    }
  }
}
