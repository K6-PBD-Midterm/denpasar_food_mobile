// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);

import 'dart:convert';

Restaurant restaurantFromJson(String str) =>
    Restaurant.fromJson(json.decode(str));

String restaurantToJson(Restaurant data) => json.encode(data.toJson());

class Restaurant {
  int? id;
  String? name;
  String? description;
  dynamic reviewsCount;
  double? rating;
  String? link;
  String? email;
  String? phone;
  String? website;
  String? imageUrl;
  Ranking? ranking;
  String? address;
  DetailedAddress? detailedAddress;
  double? latitude;
  double? longitude;
  Map<String, int>? reviewsPerRating;
  List<String>? reviewKeywords;
  bool? isOpen;
  OpenHours? openHours;
  String? menuLink;
  String? deliveryUrl;
  String? priceRange;
  List<String>? cuisines;
  List<String>? diets;
  List<String>? mealTypes;
  List<String>? diningOptions;
  List<dynamic>? ownerTypes;
  List<String>? topTags;

  Restaurant({
    this.id,
    this.name,
    this.description,
    this.reviewsCount,
    this.rating,
    this.link,
    this.email,
    this.phone,
    this.website,
    this.imageUrl,
    this.ranking,
    this.address,
    this.detailedAddress,
    this.latitude,
    this.longitude,
    this.reviewsPerRating,
    this.reviewKeywords,
    this.isOpen,
    this.openHours,
    this.menuLink,
    this.deliveryUrl,
    this.priceRange,
    this.cuisines,
    this.diets,
    this.mealTypes,
    this.diningOptions,
    this.ownerTypes,
    this.topTags,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json['name']?.toString() ?? 'No name',
        description: json['description']?.toString() ?? 'No description',
        reviewsCount: json["reviews_count"],
        rating: json['rating']?.toDouble(),
        link: json["link"],
        email: json["email"],
        phone: json["phone"],
        website: json["website"],
        imageUrl: json["image_url"],
        ranking:
            json["ranking"] != null ? Ranking.fromJson(json["ranking"]) : null,
        address: json['address']?.toString() ?? 'No address',
        detailedAddress: json["detailed_address"] != null
            ? DetailedAddress.fromJson(json["detailed_address"])
            : null,
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        reviewsPerRating: json["reviews_per_rating"] != null
            ? Map.from(json["reviews_per_rating"])
                .map((k, v) => MapEntry<String, int>(k, v))
            : null,
        reviewKeywords: json["review_keywords"] != null
            ? List<String>.from(json["review_keywords"].map((x) => x))
            : null,
        isOpen: json["is_open"],
        openHours: json["open_hours"] != null
            ? OpenHours.fromJson(json["open_hours"])
            : null,
        menuLink: json["menu_link"],
        deliveryUrl: json["delivery_url"],
        priceRange: json['price_range']?.toString() ?? 'Not specified',
        cuisines: json["cuisines"] != null
            ? List<String>.from(json["cuisines"].map((x) => x))
            : null,
        diets: json["diets"] != null
            ? List<String>.from(json["diets"].map((x) => x))
            : null,
        mealTypes: json["meal_types"] != null
            ? List<String>.from(json["meal_types"].map((x) => x))
            : null,
        diningOptions: json["dining_options"] != null
            ? List<String>.from(json["dining_options"].map((x) => x))
            : null,
        ownerTypes: json["owner_types"] != null
            ? List<dynamic>.from(json["owner_types"].map((x) => x))
            : null,
        topTags: json["top_tags"] != null
            ? List<String>.from(json["top_tags"].map((x) => x))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "reviews_count": reviewsCount,
        "rating": rating,
        "link": link,
        "email": email,
        "phone": phone,
        "website": website,
        "image_url": imageUrl,
        "ranking": ranking?.toJson(),
        "address": address,
        "detailed_address": detailedAddress?.toJson(),
        "latitude": latitude,
        "longitude": longitude,
        "reviews_per_rating": reviewsPerRating != null
            ? Map.from(reviewsPerRating!)
                .map((k, v) => MapEntry<String, dynamic>(k, v))
            : null,
        "review_keywords": reviewKeywords != null
            ? List<dynamic>.from(reviewKeywords!.map((x) => x))
            : null,
        "is_open": isOpen,
        "open_hours": openHours?.toJson(),
        "menu_link": menuLink,
        "delivery_url": deliveryUrl,
        "price_range": priceRange,
        "cuisines": cuisines != null
            ? List<dynamic>.from(cuisines!.map((x) => x))
            : null,
        "diets":
            diets != null ? List<dynamic>.from(diets!.map((x) => x)) : null,
        "meal_types": mealTypes != null
            ? List<dynamic>.from(mealTypes!.map((x) => x))
            : null,
        "dining_options": diningOptions != null
            ? List<dynamic>.from(diningOptions!.map((x) => x))
            : null,
        "owner_types": ownerTypes != null
            ? List<dynamic>.from(ownerTypes!.map((x) => x))
            : null,
        "top_tags":
            topTags != null ? List<dynamic>.from(topTags!.map((x) => x)) : null,
      };
}

class DetailedAddress {
  String? street;
  String? city;
  String? postalCode;
  dynamic state;
  String? countryCode;

  DetailedAddress({
    this.street,
    this.city,
    this.postalCode,
    this.state,
    this.countryCode,
  });

  factory DetailedAddress.fromJson(Map<String, dynamic> json) =>
      DetailedAddress(
        street: json["street"],
        city: json["city"],
        postalCode: json["postal_code"],
        state: json["state"],
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "street": street,
        "city": city,
        "postal_code": postalCode,
        "state": state,
        "country_code": countryCode,
      };
}

class OpenHours {
  List<Fri>? sun;
  List<Fri>? mon;
  List<Fri>? tue;
  List<Fri>? wed;
  List<Fri>? thu;
  List<Fri>? fri;
  List<Fri>? sat;

  OpenHours({
    this.sun,
    this.mon,
    this.tue,
    this.wed,
    this.thu,
    this.fri,
    this.sat,
  });

  factory OpenHours.fromJson(Map<String, dynamic> json) => OpenHours(
        sun: json["sun"] != null
            ? List<Fri>.from(json["sun"].map((x) => Fri.fromJson(x)))
            : null,
        mon: json["mon"] != null
            ? List<Fri>.from(json["mon"].map((x) => Fri.fromJson(x)))
            : null,
        tue: json["tue"] != null
            ? List<Fri>.from(json["tue"].map((x) => Fri.fromJson(x)))
            : null,
        wed: json["wed"] != null
            ? List<Fri>.from(json["wed"].map((x) => Fri.fromJson(x)))
            : null,
        thu: json["thu"] != null
            ? List<Fri>.from(json["thu"].map((x) => Fri.fromJson(x)))
            : null,
        fri: json["fri"] != null
            ? List<Fri>.from(json["fri"].map((x) => Fri.fromJson(x)))
            : null,
        sat: json["sat"] != null
            ? List<Fri>.from(json["sat"].map((x) => Fri.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "sun": sun != null
            ? List<dynamic>.from(sun!.map((x) => x.toJson()))
            : null,
        "mon": mon != null
            ? List<dynamic>.from(mon!.map((x) => x.toJson()))
            : null,
        "tue": tue != null
            ? List<dynamic>.from(tue!.map((x) => x.toJson()))
            : null,
        "wed": wed != null
            ? List<dynamic>.from(wed!.map((x) => x.toJson()))
            : null,
        "thu": thu != null
            ? List<dynamic>.from(thu!.map((x) => x.toJson()))
            : null,
        "fri": fri != null
            ? List<dynamic>.from(fri!.map((x) => x.toJson()))
            : null,
        "sat": sat != null
            ? List<dynamic>.from(sat!.map((x) => x.toJson()))
            : null,
      };
}

class Fri {
  String? open;
  String? close;

  Fri({
    this.open,
    this.close,
  });

  factory Fri.fromJson(Map<String, dynamic> json) => Fri(
        open: json["open"],
        close: json["close"],
      );

  Map<String, dynamic> toJson() => {
        "open": open,
        "close": close,
      };
}

class Ranking {
  int? currentRank;
  int? total;

  Ranking({
    this.currentRank,
    this.total,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) => Ranking(
        currentRank: json["current_rank"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_rank": currentRank,
        "total": total,
      };
}
