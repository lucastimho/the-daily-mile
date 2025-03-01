import React from "react";
import styled from "styled-components/native";
import Icon from "react-native-vector-icons/Ionicons";

const ActionsContainer = styled.View`
  flex-direction: row;
  justify-content: space-around;
  margin: 16px 0;
`;

const ActionButton = styled.TouchableOpacity`
  background-color: ${({ theme }) => theme.buttonBackground};
  padding: 12px 20px;
  border-radius: 30px;
  flex-direction: row;
  align-items: center;
`;

const ActionText = styled.Text`
  color: #fff;
  font-size: 16px;
  margin-left: 8px;
`;

const QuickActions = () => {
  return (
    <ActionsContainer>
      <ActionButton
        onPress={() => {
          /* Start Run action */
        }}
      >
        <Icon name="play-circle-outline" size={24} color="#fff" />
        <ActionText>Start Run</ActionText>
      </ActionButton>
      <ActionButton
        onPress={() => {
          /* View Stats action */
        }}
      >
        <Icon name="stats-chart-outline" size={24} color="#fff" />
        <ActionText>View Stats</ActionText>
      </ActionButton>
      <ActionButton
        onPress={() => {
          /* Leaderboard action */
        }}
      >
        <Icon name="trophy-outline" size={24} color="#fff" />
        <ActionText>Leaderboard</ActionText>
      </ActionButton>
    </ActionsContainer>
  );
};

export default QuickActions;
