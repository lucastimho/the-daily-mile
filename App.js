import React from "react";
import { SafeAreaView, StatusBar, useColorScheme } from "react-native";
import { ThemeProvider } from "styled-components/native";
import DashboardScreen from "./DashboardScreen";
import { lightTheme, darkTheme } from "./theme";

export default function App() {
  const colorScheme = useColorScheme();
  const theme = colorScheme === "dark" ? darkTheme : lightTheme;

  return (
    <ThemeProvider theme={theme}>
      <StatusBar barStyle={colorScheme === "dark" ? "light-content" : "dark-content"} />
      <SafeAreaView style={{ flex: 1, backgroundColor: theme.background }}>
        <DashboardScreen />
      </SafeAreaView>
    </ThemeProvider>
  );
}
