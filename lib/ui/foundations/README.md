# Design System Foundation

This directory contains the foundational design system for "Dej si pauzu" app.

## Structure

### `colors.dart`
Signature color palette and color scheme definitions.

**Signature Colors:**
- `yellow` (#FFF564) - Bright yellow
- `skyBlue` (#9FEAFF) - Light sky blue  
- `deepBlue` (#3858FB) - Primary deep blue
- `mintGreen` (#8BEF90) - Mint green
- `pink` (#FF8CDD) - Pink
- `lightGreen` (#88DD7E) - Light green
- `coral` (#EF8B8D) - Coral/salmon

**Gradient Presets:**
- `gradientSunset` - Yellow → Pink → Coral
- `gradientOcean` - Sky Blue → Deep Blue
- `gradientNature` - Mint Green → Light Green
- `gradientPlayful` - Pink → Yellow → Mint Green
- `gradientCalm` - Sky Blue → Mint Green

**Usage:**
```dart
import '../foundations/colors.dart';

// Use signature colors
Container(color: AppColors.primary)

// Use gradients
Container(decoration: BoxDecoration(gradient: AppGradients.playful))
```

### `design_tokens.dart`
Design tokens for consistent spacing, borders, shadows, and other design elements.

**Border Radius:**
- `radiusXs` (8px) - Small elements
- `radiusSm` (12px) - Buttons, chips
- `radiusMd` (16px) - Cards, inputs
- `radiusLg` (20px) - Large cards
- `radiusXl` (24px) - Dialogs
- `radiusRound` (999px) - Pills

**Shadows:**
- `shadowSm` - Subtle elevation
- `shadowMd` - Standard elevation
- `shadowLg` - Prominent elevation
- `shadowXl` - Maximum elevation

**Usage:**
```dart
import '../foundations/design_tokens.dart';

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
    boxShadow: DesignTokens.shadowMd,
  ),
)
```

### `spacing.dart`
Consistent spacing scale for padding and margins.

### `motion.dart`
Animation durations, curves, and motion constants.

## Design Principles

1. **Signature Colors First**: Use signature colors for primary actions and accents
2. **Consistent Tokens**: Always use design tokens instead of hardcoded values
3. **Playful & Modern**: Rounded corners, subtle shadows, smooth animations
4. **White Backgrounds**: Clean white surfaces with signature color accents
5. **Accessibility**: Proper contrast ratios and touch targets

## Migration Guide

When updating existing widgets:

1. Replace hardcoded colors with `AppColors.*`
2. Replace hardcoded border radius with `DesignTokens.radius*`
3. Replace hardcoded shadows with `DesignTokens.shadow*`
4. Use `AppGradients.*` for gradient backgrounds
5. Use `DesignTokens.container*` and `DesignTokens.icon*` for sizes

