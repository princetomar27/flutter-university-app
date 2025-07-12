import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertask/src/providers/providers.dart';

class UniversitySearchSection extends ConsumerWidget {
  final VoidCallback onSearch;
  final bool isLoading;

  const UniversitySearchSection({
    super.key,
    required this.onSearch,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Search Universities',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            TextField(
              controller:
                  ref
                      .read(universityViewModelProvider.notifier)
                      .searchController,
              decoration: InputDecoration(
                labelText: 'Enter Country Name',
                hintText: 'e.g., India, Japan, United States',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref
                        .read(universityViewModelProvider.notifier)
                        .searchController
                        .clear();

                    ref
                        .read(universityViewModelProvider.notifier)
                        .clearAndReloadAll();
                  },
                ),
              ),
              onSubmitted: (_) => onSearch(),
            ),

            const SizedBox(height: 16),

            // Search Button
            ElevatedButton.icon(
              onPressed: isLoading ? null : onSearch,
              icon:
                  isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.search),
              label: Text(isLoading ? 'Searching...' : 'Search Universities'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
