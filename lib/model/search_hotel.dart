class PopularStayModel {
  final bool status;
  final String message;
  final int responseCode;
  final HotelData data;

  PopularStayModel({
    required this.status,
    required this.message,
    required this.responseCode,
    required this.data,
  });

  factory PopularStayModel.fromJson(Map<String, dynamic> json) {
    return PopularStayModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      responseCode: json['responseCode'] ?? 0,
      data: HotelData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'responseCode': responseCode,
      'data': data.toJson(),
    };
  }
}

class HotelData {
  final List<PropertySearch> arrayOfHotelList;
  final List<String> arrayOfExcludedHotels;
  final List<String> arrayOfExcludedSearchType;

  HotelData({
    required this.arrayOfHotelList,
    required this.arrayOfExcludedHotels,
    required this.arrayOfExcludedSearchType,
  });

  factory HotelData.fromJson(Map<String, dynamic> json) {
    return HotelData(
      arrayOfHotelList: (json['arrayOfHotelList'] as List? ?? [])
          .map((e) => PropertySearch.fromJson(e))
          .toList(),
      arrayOfExcludedHotels: List<String>.from(
        json['arrayOfExcludedHotels'] ?? [],
      ),
      arrayOfExcludedSearchType: List<String>.from(
        json['arrayOfExcludedSearchType'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arrayOfHotelList': arrayOfHotelList.map((e) => e.toJson()).toList(),
      'arrayOfExcludedHotels': arrayOfExcludedHotels,
      'arrayOfExcludedSearchType': arrayOfExcludedSearchType,
    };
  }
}

class PropertySearch {
  final String propertyCode;
  final String propertyName;
  final PropertyImage propertyImage;
  final String propertyType;
  final int propertyStar;
  final PropertyPoliciesAndAmenities propertyPoliciesAndAmmenities;
  final PropertyAddress propertyAddress;
  final String propertyUrl;
  final String roomName;
  final int numberOfAdults;
  final Price markedPrice;
  final Price propertyMaxPrice;
  final Price propertyMinPrice;
  final List<AvailableDeal> availableDeals;
  final SubscriptionStatus subscriptionStatus;
  final int propertyView;
  final bool isFavorite;
  final SimplPriceList simplPriceList;
  final GoogleReview googleReview;

  PropertySearch({
    required this.propertyCode,
    required this.propertyName,
    required this.propertyImage,
    required this.propertyType,
    required this.propertyStar,
    required this.propertyPoliciesAndAmmenities,
    required this.propertyAddress,
    required this.propertyUrl,
    required this.roomName,
    required this.numberOfAdults,
    required this.markedPrice,
    required this.propertyMaxPrice,
    required this.propertyMinPrice,
    required this.availableDeals,
    required this.subscriptionStatus,
    required this.propertyView,
    required this.isFavorite,
    required this.simplPriceList,
    required this.googleReview,
  });

  factory PropertySearch.fromJson(Map<String, dynamic> json) {
    return PropertySearch(
      propertyCode: json['propertyCode'] ?? '',
      propertyName: json['propertyName'] ?? '',
      propertyImage: PropertyImage.fromJson(json['propertyImage'] ?? {}),
      propertyType: json['propertytype'] ?? '',
      propertyStar: json['propertyStar'] ?? 0,
      propertyPoliciesAndAmmenities: PropertyPoliciesAndAmenities.fromJson(
        json['propertyPoliciesAndAmmenities'] ?? {},
      ),
      propertyAddress: PropertyAddress.fromJson(json['propertyAddress'] ?? {}),
      propertyUrl: json['propertyUrl'] ?? '',
      roomName: json['roomName'] ?? '',
      numberOfAdults: json['numberOfAdults'] ?? 0,
      markedPrice: Price.fromJson(json['markedPrice'] ?? {}),
      propertyMaxPrice: Price.fromJson(json['propertyMaxPrice'] ?? {}),
      propertyMinPrice: Price.fromJson(json['propertyMinPrice'] ?? {}),
      availableDeals: (json['availableDeals'] as List? ?? [])
          .map((e) => AvailableDeal.fromJson(e))
          .toList(),
      subscriptionStatus: SubscriptionStatus.fromJson(
        json['subscriptionStatus'] ?? {},
      ),
      propertyView: json['propertyView'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      simplPriceList: SimplPriceList.fromJson(json['simplPriceList'] ?? {}),
      googleReview: GoogleReview.fromJson(json['googleReview'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyCode': propertyCode,
      'propertyName': propertyName,
      'propertyImage': propertyImage.toJson(),
      'propertytype': propertyType,
      'propertyStar': propertyStar,
      'propertyPoliciesAndAmmenities': propertyPoliciesAndAmmenities.toJson(),
      'propertyAddress': propertyAddress.toJson(),
      'propertyUrl': propertyUrl,
      'roomName': roomName,
      'numberOfAdults': numberOfAdults,
      'markedPrice': markedPrice.toJson(),
      'propertyMaxPrice': propertyMaxPrice.toJson(),
      'propertyMinPrice': propertyMinPrice.toJson(),
      'availableDeals': availableDeals.map((e) => e.toJson()).toList(),
      'subscriptionStatus': subscriptionStatus.toJson(),
      'propertyView': propertyView,
      'isFavorite': isFavorite,
      'simplPriceList': simplPriceList.toJson(),
      'googleReview': googleReview.toJson(),
    };
  }
}

class PropertyImage {
  final String fullUrl;
  final String location;
  final String imageName;

  PropertyImage({
    required this.fullUrl,
    required this.location,
    required this.imageName,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      fullUrl: json['fullUrl'] ?? '',
      location: json['location'] ?? '',
      imageName: json['imageName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'fullUrl': fullUrl, 'location': location, 'imageName': imageName};
  }
}

class PropertyPoliciesAndAmenities {
  final bool present;
  final AmenitiesData data;

  PropertyPoliciesAndAmenities({required this.present, required this.data});

  factory PropertyPoliciesAndAmenities.fromJson(Map<String, dynamic> json) {
    return PropertyPoliciesAndAmenities(
      present: json['present'] ?? false,
      data: AmenitiesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'present': present, 'data': data.toJson()};
  }
}

class AmenitiesData {
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

  AmenitiesData({
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

  factory AmenitiesData.fromJson(Map<String, dynamic> json) {
    return AmenitiesData(
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

  Map<String, dynamic> toJson() {
    return {
      'cancelPolicy': cancelPolicy,
      'refundPolicy': refundPolicy,
      'childPolicy': childPolicy,
      'damagePolicy': damagePolicy,
      'propertyRestriction': propertyRestriction,
      'petsAllowed': petsAllowed,
      'coupleFriendly': coupleFriendly,
      'suitableForChildren': suitableForChildren,
      'bachularsAllowed': bachularsAllowed,
      'freeWifi': freeWifi,
      'freeCancellation': freeCancellation,
      'payAtHotel': payAtHotel,
      'payNow': payNow,
      'lastUpdatedOn': lastUpdatedOn,
    };
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
      mapAddress: json['mapAddress'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'zipcode': zipcode,
      'mapAddress': mapAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Price {
  final double amount;
  final String displayAmount;
  final String currencyAmount;
  final String currencySymbol;

  Price({
    required this.amount,
    required this.displayAmount,
    required this.currencyAmount,
    required this.currencySymbol,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      displayAmount: json['displayAmount'] ?? '',
      currencyAmount: json['currencyAmount'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'displayAmount': displayAmount,
      'currencyAmount': currencyAmount,
      'currencySymbol': currencySymbol,
    };
  }
}

class AvailableDeal {
  final String headerName;
  final String websiteUrl;
  final String dealType;
  final Price price;

  AvailableDeal({
    required this.headerName,
    required this.websiteUrl,
    required this.dealType,
    required this.price,
  });

  factory AvailableDeal.fromJson(Map<String, dynamic> json) {
    return AvailableDeal(
      headerName: json['headerName'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      dealType: json['dealType'] ?? '',
      price: Price.fromJson(json['price'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headerName': headerName,
      'websiteUrl': websiteUrl,
      'dealType': dealType,
      'price': price.toJson(),
    };
  }
}

class SubscriptionStatus {
  final bool status;

  SubscriptionStatus({required this.status});

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(status: json['status'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'status': status};
  }
}

class SimplPriceList {
  final Price simplPrice;
  final double originalPrice;

  SimplPriceList({required this.simplPrice, required this.originalPrice});

  factory SimplPriceList.fromJson(Map<String, dynamic> json) {
    return SimplPriceList(
      simplPrice: Price.fromJson(json['simplPrice'] ?? {}),
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'simplPrice': simplPrice.toJson(), 'originalPrice': originalPrice};
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

  Map<String, dynamic> toJson() {
    return {'reviewPresent': reviewPresent, 'data': data?.toJson()};
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
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      totalUserRating: json['totalUserRating'] ?? 0,
      withoutDecimal: json['withoutDecimal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallRating': overallRating,
      'totalUserRating': totalUserRating,
      'withoutDecimal': withoutDecimal,
    };
  }
}
