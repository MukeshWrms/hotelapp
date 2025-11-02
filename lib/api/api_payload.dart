import 'dart:convert';

class ApiPayload {
  static ApiPayload inst = ApiPayload();

  Map<String, dynamic> searchAutoCompletePayload({
    required String inputText,
    List<String>? searchType,
    int limit = 10,
  }) {
    return {
      "action": "searchAutoComplete",
      "searchAutoComplete": {
        "inputText": inputText,
        "searchType":
            searchType ??
            ["byCity", "byState", "byCountry", "byRandom", "byPropertyName"],
        "limit": limit,
      },
    };
  }

  Map<String, dynamic> popularStayPayload({
    required String country,
    required String state,
    required String city,
    int page = 1,
    int limit = 10,
    String entityType = "Any",
    String currency = "INR",
  }) {
    return {
      "action": "popularStay",
      "popularStay": {
        "limit": limit,
        "page": page,
        "entityType": entityType,
        "filter": {
          "searchType": "byCity",
          "searchTypeInfo": {"country": country, "state": state, "city": city},
        },
        "currency": currency,
      },
    };
  }

  Map<String, dynamic> getSearchResultListOfHotelsPayload({
    required String checkIn,
    required String checkOut,
    required int rooms,
    required int adults,
    required List<String> searchQuery,
    int children = 0,
    String searchType = "hotelIdSearch",
    List<String>? accommodation,
    List<String>? excludedSearchType,
    String highPrice = "300000",
    String lowPrice = "0",
    int limit = 5,
    String currency = "INR",
    int rid = 0,
  }) {
    return {
      "action": "getSearchResultListOfHotels",
      "getSearchResultListOfHotels": {
        "searchCriteria": {
          "checkIn": checkIn,
          "checkOut": checkOut,
          "rooms": rooms,
          "adults": adults,
          "children": children,
          "searchType": searchType,
          "searchQuery": searchQuery,
          "accommodation": accommodation ?? ["all"],
          "arrayOfExcludedSearchType": excludedSearchType ?? [],
          "highPrice": highPrice,
          "lowPrice": lowPrice,
          "limit": limit,
          "preloaderList": [],
          "currency": currency,
          "rid": rid,
        },
      },
    };
  }
}
