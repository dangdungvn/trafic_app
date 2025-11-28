# Design System & Codebase Rules

## Design System Structure

### 1. Token Definitions

- **Location**: `lib/theme/app_theme.dart`
- **Structure**: Static constants within the `AppTheme` class.
- **Format**:

  ```dart
  class AppTheme {
    static const Color primaryColor = Color(0xFF4D5DFA);
    static const Color backgroundColor = Colors.white;
    // ...
  }
  ```

- **Typography**: Uses `google_fonts` package. Configured in `AppTheme.lightTheme` using `GoogleFonts.quicksandTextTheme()`.

### 2. Component Library

- **Location**: `lib/widgets/`
- **Architecture**: Flutter Stateless/Stateful widgets.
- **Common Components**:
  - `PrimaryButton` (`lib/widgets/primary_button.dart`)
  - `CustomTextField` (`lib/widgets/custom_text_field.dart`)
  - `AppButton` (`lib/widgets/app_button.dart`)
- **Documentation**: None (No Storybook).

### 3. Frameworks & Libraries

- **UI Framework**: Flutter (SDK ^3.10.0)
- **State Management**: GetX (`get`)
- **Styling/Responsive**: `flutter_screenutil`
- **Icons**: `flutter_svg`, `font_awesome_flutter`, `cupertino_icons`
- **Fonts**: `google_fonts`
- **Animations**: `lottie`
- **Maps**: `google_maps_flutter`
- **Networking**: `dio`

### 4. Asset Management

- **Storage**: `assets/` directory.
  - `assets/icons/`: SVG icons.
  - `assets/animations/`: Lottie JSON files.
  - `assets/json/`: Data files (locales, etc.).
- **Referencing**:
  - **Images/Icons**: Direct string paths (e.g., `'assets/icons/search.svg'`).
  - **Animations**: Preloaded via `AssetsService` (`lib/services/assets_service.dart`).
- **Configuration**: Assets are declared in `pubspec.yaml`.

### 5. Icon System

- **Format**: SVG (`.svg`).
- **Location**: `assets/icons/`.
- **Usage**: Used with `flutter_svg` package or as asset paths in widgets.

  ```dart
  // Example usage
  SvgPicture.asset('assets/icons/notification.svg')
  ```

- **Naming Convention**: Snake case (e.g., `home_bottom_navbar.svg`).

### 6. Styling Approach

- **Methodology**: Flutter Widget Styling.
- **Global Styles**: Defined in `AppTheme.lightTheme` (`lib/theme/app_theme.dart`).
- **Responsive Design**: Uses `flutter_screenutil` extension methods.
  - Width: `.w`
  - Height: `.h`
  - Radius: `.r`
  - Font Size: `.sp`

  ```dart
  // Example
  Container(
    width: 100.w,
    height: 50.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
    ),
  )
  ```

### 7. Project Structure

- **Pattern**: Feature-first with GetX Pattern.
- **Directory Structure**:

  ```text
  lib/
  ├── data/           # Data layer (Models, Repositories)
  ├── modules/        # Feature modules (GetX: View, Controller, Binding)
  │   ├── home/
  │   ├── dashboard/
  │   ├── login/
  │   └── ...
  ├── routes/         # Navigation (AppPages, AppRoutes)
  ├── services/       # Global services (AssetsService, etc.)
  ├── theme/          # Theme definitions (AppTheme)
  ├── widgets/        # Shared UI components
  └── main.dart       # Entry point
  ```

- **Feature Organization**: Each module typically contains `bindings/`, `controllers/`, and `views/`.
