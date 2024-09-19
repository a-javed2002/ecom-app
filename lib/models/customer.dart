class MyCustomer {
  final String id;
  final String uri;
  final String type;
  final String customer;
  final String name;
  final String address1;
  final String address2;
  final String city;
  final String contact1;
  final String contact2;

  MyCustomer({
    required this.id,
    required this.uri,
    required this.type,
    required this.customer,
    required this.name,
    required this.address1,
    required this.address2,
    required this.city,
    required this.contact1,
    required this.contact2,
  });

  factory MyCustomer.fromJson(Map<String, dynamic> json) {
    return MyCustomer(
      id: json['__metadata']['id'],
      uri: json['__metadata']['uri'],
      type: json['__metadata']['type'],
      customer: json['CUSTOMER'],
      name: json['NAME'],
      address1: json['ADDRESS1'],
      address2: json['ADDRESS2'],
      city: json['CITY'],
      contact1: json['CONTACT1'],
      contact2: json['CONTACT2'],
    );
  }
}
