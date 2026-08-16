import 'package:flutter/material.dart';
import '../../../../constants/electricity_disco.dart';

/// Dropdown-style disco picker — a 4-item grid (like NetworkSelector)
/// doesn't suit 12 options, so this uses a bordered dropdown field instead.
///
/// Deliberately doesn't set its own `fillColor`/borders: those already come
/// from the app's global `InputDecorationTheme` (see theme/app_theme.dart),
/// which is correctly light/dark-aware — same as every `AppTextField`.
/// Hardcoding a fixed fill color here would silently break in dark mode.
class DiscoSelector extends StatelessWidget {
  const DiscoSelector({super.key, required this.selected, required this.onChanged});

  final ElectricityDisco? selected;
  final ValueChanged<ElectricityDisco> onChanged;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return DropdownButtonFormField<ElectricityDisco>(
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Distribution Company',
        prefixIcon: Icon(Icons.bolt_rounded),
      ),
      hint: const Text('Select disco'),
      items: ElectricityDisco.values
          .map((disco) => DropdownMenuItem(
                value: disco,
                child: Text(disco.label, style: TextStyle(color: textColor)),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: (value) => value == null ? 'Select a distribution company' : null,
    );
  }
}
