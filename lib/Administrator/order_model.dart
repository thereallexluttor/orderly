class Order {
  final String id;
  final Map<String, dynamic> data;

  Order(this.id, this.data);

  factory Order.fromDocument(String id, Map<String, dynamic> data) {
    return Order(id, data);
  }
}
