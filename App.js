// @flow

import * as React from 'react';
import {createStackNavigator} from 'react-navigation'; // Version can be specified in package.json
import Menu from './src/components/Menu';
import Banner from './src/components/Banner';
import Interstitial from './src/components/Interstitial';
import Native from './src/components/Native';
import Video from './src/components/Video';
import VideoNative from './src/components/VideoNative';

const RootStack = createStackNavigator(
  {
    'Menu': Menu,
    'Banner': Banner,
    'Interstitial': Interstitial,
    'Native': Native,
    'Video': Video,
    'VideoNative': VideoNative
  },
  {
    'initialRouteName': 'Menu',
  }
);

export default class App extends React.Component<{}, {}> {
  render() {
    return <RootStack />;
  }
}
