// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);

import 'dart:convert';

Restaurant restaurantFromJson(String str) =>
    Restaurant.fromJson(json.decode(str));

String restaurantToJson(Restaurant data) => json.encode(data.toJson());

class Restaurant {
  int id;
  String name;
  String description;
  dynamic reviewsCount;
  int rating;
  String link;
  String email;
  String phone;
  String website;
  String imageUrl;
  Ranking ranking;
  String address;
  DetailedAddress detailedAddress;
  double latitude;
  double longitude;
  Map<String, int> reviewsPerRating;
  List<String> reviewKeywords;
  bool isOpen;
  OpenHours openHours;
  String menuLink;
  String deliveryUrl;
  String priceRange;
  List<String> cuisines;
  List<String> diets;
  List<String> mealTypes;
  List<String> diningOptions;
  List<dynamic> ownerTypes;
  List<String> topTags;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.reviewsCount,
    required this.rating,
    required this.link,
    required this.email,
    required this.phone,
    required this.website,
    required this.imageUrl,
    required this.ranking,
    required this.address,
    required this.detailedAddress,
    required this.latitude,
    required this.longitude,
    required this.reviewsPerRating,
    required this.reviewKeywords,
    required this.isOpen,
    required this.openHours,
    required this.menuLink,
    required this.deliveryUrl,
    required this.priceRange,
    required this.cuisines,
    required this.diets,
    required this.mealTypes,
    required this.diningOptions,
    required this.ownerTypes,
    required this.topTags,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        reviewsCount: json["reviews_count"],
        rating: json["rating"],
        link: json["link"],
        email: json["email"],
        phone: json["phone"],
        website: json["website"],
        imageUrl: json["image_url"],
        ranking: Ranking.fromJson(json["ranking"]),
        address: json["address"],
        detailedAddress: DetailedAddress.fromJson(json["detailed_address"]),
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        reviewsPerRating: Map.from(json["reviews_per_rating"])
            .map((k, v) => MapEntry<String, int>(k, v)),
        reviewKeywords:
            List<String>.from(json["review_keywords"].map((x) => x)),
        isOpen: json["is_open"],
        openHours: OpenHours.fromJson(json["open_hours"]),
        menuLink: json["menu_link"],
        deliveryUrl: json["delivery_url"],
        priceRange: json["price_range"],
        cuisines: List<String>.from(json["cuisines"].map((x) => x)),
        diets: List<String>.from(json["diets"].map((x) => x)),
        mealTypes: List<String>.from(json["meal_types"].map((x) => x)),
        diningOptions: List<String>.from(json["dining_options"].map((x) => x)),
        ownerTypes: List<dynamic>.from(json["owner_types"].map((x) => x)),
        topTags: List<String>.from(json["top_tags"].map((x) => x)),
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
        "ranking": ranking.toJson(),
        "address": address,
        "detailed_address": detailedAddress.toJson(),
        "latitude": latitude,
        "longitude": longitude,
        "reviews_per_rating": Map.from(reviewsPerRating)
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "review_keywords": List<dynamic>.from(reviewKeywords.map((x) => x)),
        "is_open": isOpen,
        "open_hours": openHours.toJson(),
        "menu_link": menuLink,
        "delivery_url": deliveryUrl,
        "price_range": priceRange,
        "cuisines": List<dynamic>.from(cuisines.map((x) => x)),
        "diets": List<dynamic>.from(diets.map((x) => x)),
        "meal_types": List<dynamic>.from(mealTypes.map((x) => x)),
        "dining_options": List<dynamic>.from(diningOptions.map((x) => x)),
        "owner_types": List<dynamic>.from(ownerTypes.map((x) => x)),
        "top_tags": List<dynamic>.from(topTags.map((x) => x)),
      };
}

class DetailedAddress {
  String street;
  String city;
  String postalCode;
  dynamic state;
  String countryCode;

  DetailedAddress({
    required this.street,
    required this.city,
    required this.postalCode,
    required this.state,
    required this.countryCode,
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
  List<Fri> sun;
  List<Fri> mon;
  List<Fri> tue;
  List<Fri> wed;
  List<Fri> thu;
  List<Fri> fri;
  List<Fri> sat;

  OpenHours({
    required this.sun,
    required this.mon,
    required this.tue,
    required this.wed,
    required this.thu,
    required this.fri,
    required this.sat,
  });

  factory OpenHours.fromJson(Map<String, dynamic> json) => OpenHours(
        sun: List<Fri>.from(json["sun"].map((x) => Fri.fromJson(x))),
        mon: List<Fri>.from(json["mon"].map((x) => Fri.fromJson(x))),
        tue: List<Fri>.from(json["tue"].map((x) => Fri.fromJson(x))),
        wed: List<Fri>.from(json["wed"].map((x) => Fri.fromJson(x))),
        thu: List<Fri>.from(json["thu"].map((x) => Fri.fromJson(x))),
        fri: List<Fri>.from(json["fri"].map((x) => Fri.fromJson(x))),
        sat: List<Fri>.from(json["sat"].map((x) => Fri.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sun": List<dynamic>.from(sun.map((x) => x.toJson())),
        "mon": List<dynamic>.from(mon.map((x) => x.toJson())),
        "tue": List<dynamic>.from(tue.map((x) => x.toJson())),
        "wed": List<dynamic>.from(wed.map((x) => x.toJson())),
        "thu": List<dynamic>.from(thu.map((x) => x.toJson())),
        "fri": List<dynamic>.from(fri.map((x) => x.toJson())),
        "sat": List<dynamic>.from(sat.map((x) => x.toJson())),
      };
}

class Fri {
  String open;
  String close;

  Fri({
    required this.open,
    required this.close,
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
  int currentRank;
  int total;

  Ranking({
    required this.currentRank,
    required this.total,
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
