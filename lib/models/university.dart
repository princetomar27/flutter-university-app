class University {
  final String name;
  final String country;
  final String? website;
  final List<String>? domains;
  final String? alphaTwoCode;
  final String? stateProvince;

  University({
    required this.name,
    required this.country,
    this.website,
    this.domains,
    this.alphaTwoCode,
    this.stateProvince,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      website:
          json['web_pages']?.isNotEmpty == true ? json['web_pages'][0] : null,
      domains: json['domains']?.cast<String>() ?? [],
      alphaTwoCode: json['alpha_two_code'],
      stateProvince: json['state-province'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'website': website,
      'domains': domains,
      'alpha_two_code': alphaTwoCode,
      'state-province': stateProvince,
    };
  }

  @override
  String toString() {
    return 'University(name: $name, country: $country, website: $website)';
  }
}
