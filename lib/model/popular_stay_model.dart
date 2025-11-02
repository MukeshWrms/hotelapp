class PopularStayResponse {
  final bool status;
  final String message;
  final int responseCode;
  final List<Property> data;

  PopularStayResponse({
    required this.status,
    required this.message,
    required this.responseCode,
    required this.data,
  });

  factory PopularStayResponse.fromJson(Map<String, dynamic> json) {
    return PopularStayResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      responseCode: json['responseCode'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Property.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Property {
  final String propertyName;
  final int propertyStar;
  final String propertyImage;
  final String propertyCode;
  final String propertyType;
  final PropertyPolicies propertyPoliciesAndAmmenities;
  final Price markedPrice;
  final Price staticPrice;
  final GoogleReview googleReview;
  final String propertyUrl;
  final PropertyAddress propertyAddress;

  Property({
    required this.propertyName,
    required this.propertyStar,
    required this.propertyImage,
    required this.propertyCode,
    required this.propertyType,
    required this.propertyPoliciesAndAmmenities,
    required this.markedPrice,
    required this.staticPrice,
    required this.googleReview,
    required this.propertyUrl,
    required this.propertyAddress,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      propertyName: json['propertyName'] ?? '',
      propertyStar: json['propertyStar'] ?? 0,
      propertyImage: json['propertyImage'] ?? '',
      propertyCode: json['propertyCode'] ?? '',
      propertyType: json['propertyType'] ?? '',
      propertyPoliciesAndAmmenities:
          PropertyPolicies.fromJson(json['propertyPoliciesAndAmmenities'] ?? {}),
      markedPrice: Price.fromJson(json['markedPrice'] ?? {}),
      staticPrice: Price.fromJson(json['staticPrice'] ?? {}),
      googleReview: GoogleReview.fromJson(json['googleReview'] ?? {}),
      propertyUrl: json['propertyUrl'] ?? '',
      propertyAddress: PropertyAddress.fromJson(json['propertyAddress'] ?? {}),
    );
  }
}

class PropertyPolicies {
  final bool present;
  final PoliciesData? data;

  PropertyPolicies({required this.present, this.data});

  factory PropertyPolicies.fromJson(Map<String, dynamic> json) {
    return PropertyPolicies(
      present: json['present'] ?? false,
      data: json['data'] != null ? PoliciesData.fromJson(json['data']) : null,
    );
  }
}

class PoliciesData {
  final String cancelPolicy;
  final String refundPolicy;
  final String childPolicy;
  final String damagePolicy;
  final String propertyRestriction;
  final bool petsAllowed;
  final bool coupleFriendly;
  final bool suitableForChildren;
  final bool bachularsAllowed;
  final bool freeWifi;
  final bool freeCancellation;
  final bool payAtHotel;
  final bool payNow;
  final String lastUpdatedOn;

  PoliciesData({
    required this.cancelPolicy,
    required this.refundPolicy,
    required this.childPolicy,
    required this.damagePolicy,
    required this.propertyRestriction,
    required this.petsAllowed,
    required this.coupleFriendly,
    required this.suitableForChildren,
    required this.bachularsAllowed,
    required this.freeWifi,
    required this.freeCancellation,
    required this.payAtHotel,
    required this.payNow,
    required this.lastUpdatedOn,
  });

  factory PoliciesData.fromJson(Map<String, dynamic> json) {
    return PoliciesData(
      cancelPolicy: json['cancelPolicy'] ?? '',
      refundPolicy: json['refundPolicy'] ?? '',
      childPolicy: json['childPolicy'] ?? '',
      damagePolicy: json['damagePolicy'] ?? '',
      propertyRestriction: json['propertyRestriction'] ?? '',
      petsAllowed: json['petsAllowed'] ?? false,
      coupleFriendly: json['coupleFriendly'] ?? false,
      suitableForChildren: json['suitableForChildren'] ?? false,
      bachularsAllowed: json['bachularsAllowed'] ?? false,
      freeWifi: json['freeWifi'] ?? false,
      freeCancellation: json['freeCancellation'] ?? false,
      payAtHotel: json['payAtHotel'] ?? false,
      payNow: json['payNow'] ?? false,
      lastUpdatedOn: json['lastUpdatedOn'] ?? '',
    );
  }
}

class Price {
  final double amount;
  final String displayAmount;
  final String currencySymbol;

  Price({
    required this.amount,
    required this.displayAmount,
    required this.currencySymbol,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      amount: (json['amount'] ?? 0).toDouble(),
      displayAmount: json['displayAmount'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
    );
  }
}

class GoogleReview {
  final bool reviewPresent;
  final ReviewData? data;

  GoogleReview({required this.reviewPresent, this.data});

  factory GoogleReview.fromJson(Map<String, dynamic> json) {
    return GoogleReview(
      reviewPresent: json['reviewPresent'] ?? false,
      data: json['data'] != null ? ReviewData.fromJson(json['data']) : null,
    );
  }
}

class ReviewData {
  final double overallRating;
  final int totalUserRating;
  final int withoutDecimal;

  ReviewData({
    required this.overallRating,
    required this.totalUserRating,
    required this.withoutDecimal,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      overallRating: (json['overallRating'] ?? 0).toDouble(),
      totalUserRating: json['totalUserRating'] ?? 0,
      withoutDecimal: json['withoutDecimal'] ?? 0,
    );
  }
}

class PropertyAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipcode;
  final String mapAddress;
  final double latitude;
  final double longitude;

  PropertyAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipcode,
    required this.mapAddress,
    required this.latitude,
    required this.longitude,
  });

  factory PropertyAddress.fromJson(Map<String, dynamic> json) {
    return PropertyAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipcode: json['zipcode'] ?? '',
      mapAddress: json['map_address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
