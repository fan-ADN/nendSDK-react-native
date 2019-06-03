// @flow

'use strict'

import * as React from 'react';
import {
  StyleSheet,
  Platform,
  Alert,
  View
} from 'react-native';
import {InterstitialAd} from 'react-native-nend-bridger';
import type {ClickType} from 'react-native-nend-bridger';
import Button from './Button'

export default class Interstitial extends React.Component<{}, {}> {
    static navigationOptions = {
        title: 'Interstitial',
    };

    constructor() {
        super();
        InterstitialAd.setAutoReloadEnabled(false); // 広告の自動リロードを無効 (デフォルトは有効)
        InterstitialAd.onInterstitialAdClosed = (spotId: string, type: ClickType) => {
            console.log(`onInterstitialAdClosed: ${spotId}, ${type}`);
        };
    }

    async _onClickLoad() {
        try {
            if (Platform.OS === 'ios') {
                await InterstitialAd.loadAd('213208', '308c2499c75c4a192f03c02b2fcebd16dcb45cc9');
            } else {
                await InterstitialAd.loadAd('213206', '8c278673ac6f676dae60a1f56d16dad122e23516');
            }
            Alert.alert('Success');
        } catch (err) {
            Alert.alert(err.message);
        }
    }

    async _onClickShow() {
        try {
            if (Platform.OS === 'ios') {
                await InterstitialAd.show('213208');
            } else {
                await InterstitialAd.show('213206');
            }
        } catch (err) {
            Alert.alert(err.message);
        }
    }

    render() {
        return (
          <View style={styles.container}>
            <Button title={'Load'} onPress={this._onClickLoad} />
            <Button title={'Show'} onPress={this._onClickShow} />
          </View>
        )
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
