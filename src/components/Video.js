// @flow

'use strict'

import * as React from 'react';
import {
  StyleSheet,
  Platform,
  Alert,
  View
} from 'react-native';
import {
  RewardedVideoAd,
  InterstitialVideoAd
} from '../ad/VideoAd';
import type {RewardItem} from '../ad/VideoAd';
import Button from './Button'
import UserFeature from '../ad/UserFeature';

export default class Video extends React.Component<{}, {}> {
    rewardedVideoAd: RewardedVideoAd;
    interstitialVideoAd: InterstitialVideoAd;

    static navigationOptions = {
        title: 'Video',
    };

    constructor() {
        super();
        if (Platform.OS === 'ios') {
            this.rewardedVideoAd = new RewardedVideoAd('802555', 'ca80ed7018734d16787dbda24c9edd26c84c15b8');
            this.interstitialVideoAd = new InterstitialVideoAd('802557', 'b6a97b05dd088b67f68fe6f155fb3091f302b48b');
        } else {
            this.rewardedVideoAd = new RewardedVideoAd('802558', 'a6eb8828d64c70630fd6737bd266756c5c7d48aa');
            this.interstitialVideoAd = new InterstitialVideoAd('802559', 'e9527a2ac8d1f39a667dfe0f7c169513b090ad44');
        }
        this.rewardedVideoAd.onRewarded = (item: RewardItem) => {
            console.log(`Got reward: ${item.name} ${item.amount}`);
        };
        this.interstitialVideoAd.onVideoShown = () => {
            console.log('onVideoShown');
        };
        this.interstitialVideoAd.onVideoClosed = () => {
            console.log('onVideoClosed');
        };
        // https://github.com/fan-ADN/nendSDK-iOS/wiki/%E5%8B%95%E7%94%BB%E3%83%AA%E3%83%AF%E3%83%BC%E3%83%89%E5%BA%83%E5%91%8A%E5%AE%9F%E8%A3%85%E6%89%8B%E9%A0%86#%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E5%B1%9E%E6%80%A7%E3%81%AE%E8%A8%AD%E5%AE%9A
        const feature = new UserFeature();
        feature.setGender('Male');
        feature.setAge(20);
        feature.setBirthday(2000, 1, 1);
        feature.addCustomValue('customStringValue', 'stringValue');
        feature.addCustomValue('customBooleanValue', true);
        feature.addCustomValue('customIntegerValue', 12345);
        feature.addCustomValue('customDoubleValue', 123.45);
        this.rewardedVideoAd.setUserFeature(feature);
        // this.interstitialVideoAd.setUserFeature(feature);
        feature.destroy();
    }

    componentWillUnmount() {
        this.rewardedVideoAd.destroy();
        this.interstitialVideoAd.destroy();
    }

    render() {
        return (
          <View style={styles.container}>
            <Button 
                title='Load and Show rewarded video ad' 
                onPress={async () => {
                    try {
                        await this.rewardedVideoAd.loadAd();
                        const isReady: boolean = await this.rewardedVideoAd.isLoaded();
                        if (isReady) {
                            this.rewardedVideoAd.show();
                        }
                    } catch (err) {
                        Alert.alert(`${err}`);
                    }
                }} 
            />
            <Button 
                title='Load and Show interstitial video ad'
                onPress={async () => {
                    try {
                        await this.interstitialVideoAd.loadAd();
                        const isReady: boolean = await this.interstitialVideoAd.isLoaded();
                        if (isReady) {
                            this.interstitialVideoAd.show();
                        }
                    } catch (err) {
                        Alert.alert(`${err}`);
                    }
                }}
            />
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
  },
});
