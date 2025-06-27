# BruteForcer

A Flutter application that generates and manages permutations of character strings. The application works on both Android devices and web browsers.

## Features

- **String Generation**:
  - Generate all possible permutations based on:
    - String length (1-5 characters)
    - Character sets:
      - Numbers (0-9)
      - Small letters (a-z)
      - Big letters (A-Z)
  - Preview the number of permutations before generation

- **Run Management**:
  - Create multiple named runs with different settings
  - Switch between runs
  - Delete unwanted runs
  - Persistent storage (runs are saved between app restarts)

- **Interactive Grid View**:
  - Display permutations in rectangular tiles
  - Tap a tile to mark it as used
  - Used tiles are automatically removed
  - Grid dynamically reflows to fill available space

## Getting Started

### Prerequisites

- Flutter SDK (installed and added to PATH)
- Android Studio with Android SDK for Android development
- Chrome browser for web development
- An Android device or emulator for mobile testing

### Installation

1. Clone the repository:
   ```bash
   git clone [repository-url]
   cd brute_force
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the Application

#### For Web:
```bash
flutter run -d chrome
```

#### For Android:

1. **Using Physical Device**:
   - Enable Developer Options on your Android device:
     1. Go to Settings > About phone
     2. Tap "Build number" 7 times
     3. Go back to Settings > System > Developer options
     4. Enable "USB debugging"
   - Connect your device via USB
   - Run:
     ```bash
     flutter run -d android
     ```

2. **Using Emulator**:
   - Open Android Studio
   - Create and start an Android Virtual Device (AVD)
   - Run:
     ```bash
     flutter run
     ```

## Usage

1. **Creating a New Run**:
   - Set desired string length using the slider
   - Select character sets (numbers, small letters, big letters)
   - Click the '+' button
   - Enter a name for the run
   - Review the number of permutations
   - Click 'Create'

2. **Managing Runs**:
   - Click the run name in the app bar to switch between runs
   - Use the delete icon next to a run's name to remove it
   - Confirm deletion when prompted

3. **Using the Grid**:
   - Each tile shows a unique permutation
   - Tap a tile to mark it as used
   - Used tiles are removed automatically
   - Remaining tiles reflow to fill the space

## Technical Details

- Built with Flutter
- Uses Material Design 3
- Implements persistent storage using shared_preferences
- Supports both web and Android platforms
- Responsive design that adapts to different screen sizes
