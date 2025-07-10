import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import '../models/university.dart';
import '../utils/country_utils.dart';

class UniversityCard extends StatelessWidget {
  final University university;
  final VoidCallback? onTap;
  final VoidCallback? onWebsiteTap;

  const UniversityCard({
    super.key,
    required this.university,
    this.onTap,
    this.onWebsiteTap,
  });

  String _getCountryCode(String countryName) {
    return CountryUtils.getCountryCode(countryName);
  }

  @override
  Widget build(BuildContext context) {
    final countryCode = _getCountryCode(university.country);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          university.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CountryFlag.fromCountryCode(
                              countryCode,
                              height: 16,
                              width: 24,
                              borderRadius: 2,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              university.country,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (university.website != null)
                    IconButton(
                      onPressed: onWebsiteTap,
                      icon: const Icon(Icons.language),
                      tooltip: 'Visit Website',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              if (university.domains?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  'Domains: ${university.domains!.join(', ')}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
