class Company {
  final int id;        // ID of the company
  final String logo;   // Company logo URL
  final String name;   // Company name
  final String phone;  // Phone number
  final String address; // Address

  Company({
    required this.id,
    required this.logo,
    required this.name,
    required this.phone,
    required this.address,
  });

  // Factory constructor to create a Company object from a JSON map
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],                           // Assuming 'id' is always present
      logo: json['logo'] ?? '',                 // Provide default if null
      name: json['name'] ?? 'Unknown',          // Provide default if null
      phone: json['phone'] ?? 'No phone',       // Provide default if null
      address: json['address'] ?? 'No address', // Provide default if null
    );
  }

  // Method to convert a Company object to a JSON map (for sending data)
  Map<String, dynamic> toJson() {
    return {
      'id': id,         // Include 'id' if necessary for the API
      'logo': logo,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}
