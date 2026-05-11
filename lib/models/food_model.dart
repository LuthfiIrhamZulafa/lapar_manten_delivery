class Food {
  final String name;
  final String category;
  final String distance;
  final double rating;
  final String totalReviews;
  final double originalPrice;
  final double discountPrice;
  final String imageUrl;
  final bool isPromo;

  Food({
    required this.name,
    required this.category,
    required this.distance,
    required this.rating,
    required this.totalReviews,
    required this.originalPrice,
    required this.discountPrice,
    required this.imageUrl,
    this.isPromo = false,
  });
}

// Data Dummy untuk testing sesuai gambar Beranda.jpg
List<Food> dummyFoods = [
  Food(
    name: "Mie Gacoan",
    category: "Noodles",
    distance: "2.4 km",
    rating: 4.8,
    totalReviews: "1.2k+",
    originalPrice: 65000,
    discountPrice: 42000,
    imageUrl: "assets/images/gacoan.png",
    isPromo: true,
  ),
  Food(
    name: "Roti'o - Asia Plaza",
    category: "Coffee • Roti",
    distance: "3.1 km",
    rating: 4.9,
    totalReviews: "800+",
    originalPrice: 125000,
    discountPrice: 125000, // Tidak diskon
    imageUrl: "assets/images/roti'o.png",
    isPromo: false,
  ),
];
