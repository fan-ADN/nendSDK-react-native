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
