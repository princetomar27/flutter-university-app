import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_flags/country_flags.dart';
import '../providers/providers.dart';
import '../models/university.dart';
import '../utils/country_utils.dart';

class UniversityDetailScreen extends ConsumerStatefulWidget {
  final String universityName;

  const UniversityDetailScreen({super.key, required this.universityName});

  @override
  ConsumerState<UniversityDetailScreen> createState() =>
      _UniversityDetailScreenState();
}

class _UniversityDetailScreenState
    extends ConsumerState<UniversityDetailScreen> {
  University? university;

  @override
  void initState() {
    super.initState();
    _findUniversity();
  }

  void _findUniversity() {
    final state = ref.read(universityViewModelProvider);
    university = state.universities.firstWhere(
      (uni) => uni.name == widget.universityName,
      orElse: () => University(name: widget.universityName, country: 'Unknown'),
    );
  }

  String _getCountryCode(String countryName) {
    return CountryUtils.getCountryCode(countryName);
  }

  void _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (university == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('University Details'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: Text('University not found')),
      );
    }

    final countryCode = _getCountryCode(university!.country);

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Header
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                university!.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CountryFlag.fromCountryCode(
                                    countryCode,
                                    height: 20,
                                    width: 30,
                                    borderRadius: 3,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    university!.country,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // University Details
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'University Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Website Section
                    if (university!.website != null) ...[
                      _buildDetailRow(
                        'Website',
                        university!.website!,
                        Icons.language,
                        () => _openWebsite(university!.website!),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Country Section
                    _buildDetailRow('Country', university!.country, Icons.flag),

                    // State/Province Section
                    if (university!.stateProvince != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'State/Province',
                        university!.stateProvince!,
                        Icons.location_city,
                      ),
                    ],

                    // Alpha Two Code Section
                    if (university!.alphaTwoCode != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Country Code',
                        university!.alphaTwoCode!,
                        Icons.code,
                      ),
                    ],

                    // Domains Section
                    if (university!.domains?.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Domains',
                        university!.domains!.join(', '),
                        Icons.domain,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (university!.website != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openWebsite(university!.website!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Visit Official Website'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, [
    VoidCallback? onTap,
  ]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        onTap != null
                            ? Theme.of(context).colorScheme.primary
                            : null,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
