import React from "react";
import styled from "styled-components/native";
import Icon from "react-native-vector-icons/Ionicons";

const NavContainer = styled.View`
  flex-direction: row;
  justify-content: space-around;
  align-items: center;
  padding: 10px 0;
  background-color: ${({ theme }) => theme.navBackground};
  border-top-width: 1px;
  border-top-color: #ddd;
`;

const NavItem = styled.TouchableOpacity`
  flex: 1;
  align-items: center;
`;

const NavLabel = styled.Text`
  font-size: 12px;
  color: ${({ theme }) => theme.textColor};
  margin-top: 4px;
`;

const BottomNavigation = () => {
  return (
    <NavContainer>
      <NavItem
        onPress={() => {
          /* Navigate Home */
        }}
      >
        <Icon name="home-outline" size={24} color="#000" />
        <NavLabel>Home</NavLabel>
      </NavItem>
      <NavItem
        onPress={() => {
          /* Navigate Activity */
        }}
      >
        <Icon name="fitness-outline" size={24} color="#000" />
        <NavLabel>Activity</NavLabel>
      </NavItem>
      <NavItem
        onPress={() => {
          /* Navigate Friends */
        }}
      >
        <Icon name="people-outline" size={24} color="#000" />
        <NavLabel>Friends</NavLabel>
      </NavItem>
      <NavItem
        onPress={() => {
          /* Navigate Profile */
        }}
      >
        <Icon name="person-outline" size={24} color="#000" />
        <NavLabel>Profile</NavLabel>
      </NavItem>
    </NavContainer>
  );
};

export default BottomNavigation;
