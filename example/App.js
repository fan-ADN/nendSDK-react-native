/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View} from 'react-native';

import { createStackNavigator, createAppContainer } from "react-navigation";
import Menu from './src/components/Menu';
import Banner from './src/components/Banner';
import Interstitial from './src/components/Interstitial';
import Native from './src/components/Native';
import Video from './src/components/Video';
import VideoNative from './src/components/VideoNative';

const AppNavigator = createStackNavigator(
    {
      Menu: Menu,
      Banner: Banner,
      Interstitial: Interstitial,
      Native: Native,
      Video: Video,
      VideoNative: VideoNative
    },
    {
      initialRouteName: "Menu"
    }
);

const AppContainer = createAppContainer(AppNavigator);

export default class App extends React.Component {
  render() {
    return <AppContainer />;
  }
}
