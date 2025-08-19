import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/space_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCity;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    final sp = context.read<SpaceProvider>();
    _selectedCity = sp.selectedCity;
    _maxPrice = sp.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<SpaceProvider>(
        builder: (context, sp, _) {
          final cities = sp.cities;
          double maxPossible = 0;
          for (final s in sp.spaces) {
            if (s.pricePerHour > maxPossible) maxPossible = s.pricePerHour;
          }
          if (maxPossible <= 0) maxPossible = 1000;
          final sliderValue = (_maxPrice ?? maxPossible).clamp(0, maxPossible).toDouble();

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('City', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: _selectedCity,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All cities'),
                    ),
                    ...cities.map((c) => DropdownMenuItem<String?>(
                          value: c,
                          child: Text(c),
                        )),
                  ],
                  onChanged: (value) => setState(() => _selectedCity = value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Max price/hour', style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('₹${sliderValue.toInt()}'),
                  ],
                ),
                Slider(
                  value: sliderValue,
                  min: 0,
                  max: maxPossible,
                  divisions: 20,
                  label: '₹${sliderValue.toInt()}',
                  onChanged: (v) => setState(() => _maxPrice = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        sp.clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear all'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        sp.filterByCity(_selectedCity);
                        sp.filterByPrice(_maxPrice);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}