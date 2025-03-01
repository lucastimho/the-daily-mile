import React from "react";
import { View } from "react-native";
import Animated, { FadeIn } from "react-native-reanimated";
import Header from "./components/Header";
import ActivityOverview from "./components/ActivityOverview";
import PerformanceGraph from "./components/PerformanceGraph";
import QuickActions from "./components/QuickActions";
import BottomNavigation from "./components/BottomNavigation";

const DashboardScreen = () => {
  return (
    <View style={{ flex: 1 }}>
      <Animated.ScrollView contentContainerStyle={{ padding: 16 }} entering={FadeIn.duration(500)}>
        <Header />
        <ActivityOverview />
        <PerformanceGraph />
        <QuickActions />
      </Animated.ScrollView>
      <BottomNavigation />
    </View>
  );
};

export default DashboardScreen;
