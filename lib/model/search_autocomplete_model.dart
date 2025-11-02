class SearchAutoCompleteResponse {
  final bool status;
  final String message;
  final int responseCode;
  final SearchData? data;

  SearchAutoCompleteResponse({
    required this.status,
    required this.message,
    required this.responseCode,
    required this.data,
  });

  factory SearchAutoCompleteResponse.fromJson(Map<String, dynamic> json) {
    return SearchAutoCompleteResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      responseCode: json['responseCode'] ?? 0,
      data: json['data'] != null ? SearchData.fromJson(json['data']) : null,
    );
  }
}

class SearchData {
  final bool present;
  final int totalNumberOfResult;
  final AutoCompleteList autoCompleteList;

  SearchData({
    required this.present,
    required this.totalNumberOfResult,
    required this.autoCompleteList,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      present: json['present'] ?? false,
      totalNumberOfResult: json['totalNumberOfResult'] ?? 0,
      autoCompleteList: AutoCompleteList.fromJson(json['autoCompleteList']),
    );
  }
}

class AutoCompleteList {
  final CategoryResult? byPropertyName;
  final CategoryResult? byStreet;
  final CategoryResult? byCity;
  final CategoryResult? byState;
  final CategoryResult? byCountry;

  AutoCompleteList({
    this.byPropertyName,
    this.byStreet,
    this.byCity,
    this.byState,
    this.byCountry,
  });

  factory AutoCompleteList.fromJson(Map<String, dynamic> json) {
    return AutoCompleteList(
      byPropertyName: json['byPropertyName'] != null
          ? CategoryResult.fromJson(json['byPropertyName'])
          : null,
      byStreet: json['byStreet'] != null
          ? CategoryResult.fromJson(json['byStreet'])
          : null,
      byCity: json['byCity'] != null
          ? CategoryResult.fromJson(json['byCity'])
          : null,
      byState: json['byState'] != null
          ? CategoryResult.fromJson(json['byState'])
          : null,
      byCountry: json['byCountry'] != null
          ? CategoryResult.fromJson(json['byCountry'])
          : null,
    );
  }
}

class CategoryResult {
  final bool present;
  final int numberOfResult;
  final List<SearchResult> listOfResult;

  CategoryResult({
    required this.present,
    required this.numberOfResult,
    required this.listOfResult,
  });

  factory CategoryResult.fromJson(Map<String, dynamic> json) {
    return CategoryResult(
      present: json['present'] ?? false,
      numberOfResult: json['numberOfResult'] ?? 0,
      listOfResult: json['listOfResult'] != null
          ? (json['listOfResult'] as List)
                .map((e) => SearchResult.fromJson(e))
                .toList()
          : [],
    );
  }
}

class SearchResult {
  final String? valueToDisplay;
  final String? propertyName;
  final Address? address;
  final SearchArray? searchArray;

  SearchResult({
    this.valueToDisplay,
    this.propertyName,
    this.address,
    this.searchArray,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      valueToDisplay: json['valueToDisplay'],
      propertyName: json['propertyName'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      searchArray: json['searchArray'] != null
          ? SearchArray.fromJson(json['searchArray'])
          : null,
    );
  }
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? country;

  Address({this.street, this.city, this.state, this.country});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }
}

class SearchArray {
  final String? type;
  final List<String> query;

  SearchArray({this.type, required this.query});

  factory SearchArray.fromJson(Map<String, dynamic> json) {
    return SearchArray(
      type: json['type'],
      query: json['query'] != null
          ? List<String>.from(json['query'])
          : <String>[],
    );
  }
}
