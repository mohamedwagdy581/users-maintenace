class RequestModel {
  String? uId;
  late String city;
  late String companyName;
  late String school;
  late String phone;
  late String machine;
  late double latitude;
  late double longitude;
  late String consultation;

  RequestModel({
    this.uId = '',
    required this.city,
    required this.companyName,
    required this.school,
    required this.phone,
    required this.machine,
    required this.latitude,
    required this.longitude,
    required this.consultation,
  });

  Map<String, dynamic> toJson() =>
  {
    'uId' : uId,
    'city' : city,
    'companyName' : companyName,
    'school' : school,
    'phone' : phone,
    'machine' : machine,
    'latitude' : latitude,
    'longitude' : longitude,
    'consultation' : consultation,
  };

  RequestModel.fromJson(Map<String, dynamic> json)
  {
    uId = json['uId'];
    city = json['city'];
    companyName = json['companyName'];
    school = json['school'];
    phone = json['phone'];
    machine = json['machine'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    consultation = json['consultation'];
  }
}
