import React from "react";
import { Dimensions } from "react-native";
import { LineChart } from "react-native-chart-kit";
import styled from "styled-components/native";

const GraphContainer = styled.View`
  margin: 16px 0;
`;

const PerformanceGraph = () => {
  // Sample data for the past week
  const data = {
    labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    datasets: [
      {
        data: [3, 4, 3.5, 5, 4.2, 4.8, 5],
        color: (opacity = 1) => `rgba(134, 65, 244, ${opacity})`,
        strokeWidth: 2,
      },
    ],
    legend: ["Distance (km)"],
  };

  return (
    <GraphContainer>
      <LineChart
        data={data}
        width={Dimensions.get("window").width - 32}
        height={220}
        chartConfig={{
          backgroundColor: "#fff",
          backgroundGradientFrom: "#fff",
          backgroundGradientTo: "#fff",
          decimalPlaces: 1,
          color: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
          labelColor: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
          style: {
            borderRadius: 16,
          },
          propsForDots: {
            r: "4",
            strokeWidth: "2",
            stroke: "#ffa726",
          },
        }}
        bezier
        style={{
          borderRadius: 16,
        }}
      />
    </GraphContainer>
  );
};

export default PerformanceGraph;
