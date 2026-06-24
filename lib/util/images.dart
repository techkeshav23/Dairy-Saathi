/// Asset path constants. The app ships with a programmatic logo (no binary
/// asset required) but these paths are kept ready for branded artwork.
class Images {
  Images._();

  static const String _path = 'assets/images';

  static const String logo = '$_path/logo.png';
  static const String placeholder = '$_path/placeholder.png';
  static const String emptyCart = '$_path/empty_cart.png';
  static const String emptyOrders = '$_path/empty_orders.png';
}
