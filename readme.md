# The Daily Mile

The Daily Mile is a React Native prototype for a running app dashboard that re-imagines the UI/UX of popular fitness apps like Strava. Designed with modern aesthetics and user-centric features, The Daily Mile delivers a sleek and engaging experience for tracking your runs, monitoring performance, and accessing quick actions—all optimized for both iOS and Android.

## Features

- **Header Section:**

  - Displays the user’s profile picture, name, and a welcome message.
  - Includes a settings icon for quick navigation.

- **Activity Overview:**

  - Showcases the latest run stats such as distance, pace, time, and calories burned.
  - Uses cards with dynamic color gradients for a visually appealing display.

- **Performance Graph:**

  - Renders an interactive line graph (powered by `react-native-chart-kit`) to display running trends.
  - Features smooth animations for a modern feel.

- **Quick Action Buttons:**

  - Provides large, rounded buttons to quickly access key actions like "Start Run", "View Stats", and "Leaderboard".
  - Integrates professional iconography using `react-native-vector-icons`.

- **Bottom Navigation Bar:**
  - Offers a minimalistic navigation interface with tabs for Home, Activity, Friends, and Profile.
  - Inspired by Apple’s Human Interface Guidelines for clean and intuitive navigation.

## Technologies Used

- **React Native (Expo):** Core framework for building the cross-platform mobile application.
- **Styled-Components:** For theming and responsive styling (supports both light and dark modes).
- **Expo-Linear-Gradient:** Provides gradient components that are web-compatible.
- **React Native Chart Kit:** Used for creating engaging and animated performance graphs.
- **React Native Vector Icons:** Enhances the UI with a variety of customizable icons.
- **React Native Reanimated:** Enables smooth animations and transitions.
- **React Native SVG:** Handles SVG rendering for charts and other graphics.

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/lucastimho/the-daily-mile.git
   cd the-daily-mile
   ```
