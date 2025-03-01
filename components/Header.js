import React from "react";
import { TouchableOpacity } from "react-native";
import styled from "styled-components/native";
import Icon from "react-native-vector-icons/Ionicons";

const HeaderContainer = styled.View`
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
`;

const ProfileContainer = styled.View`
  flex-direction: row;
  align-items: center;
`;

const ProfileImage = styled.Image`
  width: 50px;
  height: 50px;
  border-radius: 25px;
  margin-right: 12px;
`;

const GreetingText = styled.Text`
  font-size: 18px;
  font-weight: bold;
  color: ${({ theme }) => theme.textColor};
`;

const Header = () => {
  // Sample user data
  const user = {
    name: "John Doe",
    profilePicture: "https://placekitten.com/100/100",
  };

  return (
    <HeaderContainer>
      <ProfileContainer>
        <ProfileImage source={{ uri: user.profilePicture }} />
        <GreetingText>Welcome, {user.name}</GreetingText>
      </ProfileContainer>
      <TouchableOpacity
        onPress={() => {
          /* navigate to settings */
        }}
      >
        <Icon name="settings-outline" size={28} color={user.iconColor || "#000"} />
      </TouchableOpacity>
    </HeaderContainer>
  );
};

export default Header;
