# TODO for HandleCrash App Updates

## Current Task: Add description and navigation buttons to Homepage

### Steps:
1. [x] Edit lib/main.dart: Modify the Homepage widget in _widgetOptions to pass a callback function (onNavigate: (int index) { _onItemTapped(index); }) to Homepage.
2. [x] Edit lib/homepage.dart: Accept the onNavigate callback as a parameter. Expand the description to be more intuitive (e.g., "HandleCrash te ayuda a detectar daños en vehículos con IA, acceder a emergencias y guías de reparación."). Add three ElevatedButton widgets below the description for navigating to Camera (index 1), Emergency (index 2), and External Link (index 3). Style buttons consistently with the theme (pastel green, shadows).
3. [x] Run `flutter pub get` to ensure dependencies are up to date.
4. [x] Test the app: Run `flutter run`, verify the homepage shows the new description and buttons, and confirm tapping buttons navigates to the correct screens without errors.
5. [x] Update this TODO.md with progress (mark as [x] when complete).

### Dependent Files:
- lib/main.dart
- lib/homepage.dart

### Followup:
- Task complete.
