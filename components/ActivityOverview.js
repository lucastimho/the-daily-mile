import React from "react";
import { View } from "react-native";
import styled from "styled-components/native";
import { LinearGradient } from "expo-linear-gradient";

const Card = styled(LinearGradient)`
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 12px;
  elevation: 3;
  shadow-color: #000;
  shadow-opacity: 0.1;
  shadow-radius: 6px;
  shadow-offset: 0px 2px;
`;

const StatText = styled.Text`
  font-size: 16px;
  font-weight: bold;
  color: #fff;
`;

const ActivityOverview = () => {
  // Sample run stats
  const stats = {
    distance: "5.2 km",
    pace: "5:30 /km",
    time: "28:34",
    calories: "350 kcal",
  };

  return (
    <View>
      <Card colors={["#4facfe", "#00f2fe"]}>
        <StatText>Distance: {stats.distance}</StatText>
      </Card>
      <Card colors={["#43e97b", "#38f9d7"]}>
        <StatText>Pace: {stats.pace}</StatText>
      </Card>
      <Card colors={["#fa709a", "#fee140"]}>
        <StatText>Time: {stats.time}</StatText>
      </Card>
      <Card colors={["#a1c4fd", "#c2e9fb"]}>
        <StatText>Calories: {stats.calories}</StatText>
      </Card>
    </View>
  );
};

export default ActivityOverview;
