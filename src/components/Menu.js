// @flow

'use strict'

import * as React from 'react';
import { NavigationScreenProp } from 'react-navigation';
import {
  StyleSheet,
  View
} from 'react-native';
import Button from './Button'

type Props = {
    navigation: NavigationScreenProp<{}>,
}

export default class Menu extends React.Component<Props> {
    static navigationOptions = {
        title: 'Welcome',
    };
    
    render() {
        const { navigate } = this.props.navigation;
        return (
          <View style={styles.container}>
            <Button onPress={() => navigate('Banner')} title={'Go to banner ad example'} />
            <Button onPress={() => navigate('Interstitial')} title={'Go to interstitial ad example'} />
            <Button onPress={() => navigate('Native')} title={'Go to native ad example'} />
            <Button onPress={() => navigate('Video')} title={'Go to video ad example'} />
            <Button onPress={() => navigate('VideoNative')} title={'Go to video native ad example'} />
          </View>
        );
    }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  }
});